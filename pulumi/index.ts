import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";

export = async () => {
  const project = new pulumi.Config("gcp").require("project");
  const region = new pulumi.Config("gcp").require("region");
  const zone = new pulumi.Config("gcp").require("zone");
  const image = new pulumi.Config("palworld").require("image");
  const settings: Record<string, string> = new pulumi.Config(
    "palworld"
  ).requireObject("settings");

  const provider = new gcp.Provider("gcp-provider", { project, region, zone });

  // request a static ip address for the server
  const ipAddress = new gcp.compute.Address("palworld-ip", {}, { provider });

  // provision a persistent disk for the server used for storing server data
  const dataDisk = new gcp.compute.Disk(
    "palworld-data-disk",
    {
      size: 10,
    },
    { provider }
  );

  // configure the persistent disk to have daily snapshots taken at ~4:00 PST
  const dataDiskPolicy = new gcp.compute.ResourcePolicy(
    "palworld-data-disk-snapshot-policy",
    {
      snapshotSchedulePolicy: {
        retentionPolicy: {
          onSourceDiskDelete: "APPLY_RETENTION_POLICY",
          maxRetentionDays: 7,
        },
        schedule: {
          dailySchedule: {
            daysInCycle: 1,
            startTime: "12:00",
          },
        },
      },
    },
    { provider }
  );
  const dataDiskSnapshotPolicy = new gcp.compute.DiskResourcePolicyAttachment(
    "palworld-data-disk-policy-attachment",
    {
      disk: dataDisk.name,
      name: dataDiskPolicy.name,
    },
    { provider }
  );

  // create a service account to attach to the instance
  const serviceAccount = new gcp.serviceaccount.Account(
    "palworld-service-account",
    {
      accountId: "palworld-service-account",
    },
    { provider }
  );
  for (const role of ["monitoring.metricWriter", "logging.logWriter"]) {
    new gcp.projects.IAMMember(
      `palworld-sa-binding-${role}`,
      {
        member: serviceAccount.email.apply(
          (email) => `serviceAccount:${email}`
        ),
        role: `roles/${role}`,
        project,
      },
      { provider }
    );
  }

  // define a script that will get run whenever the vm is started up
  // NOTE: must be tolerant of restarts
  const serverScript = `#!/usr/bin/env sh
  set -e
  # disable interactivity when using apt
  export DEBIAN_FRONTEND=noninteractive

  # install docker
  apt -y update
  apt -y install ca-certificates curl gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker.list
  apt -y update
  apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # format data volume if needed
  apt -y install fdisk
  disk_fs_type="$(sudo blkid -o value -s TYPE /dev/disk/by-id/google-persistent-disk-1 || echo "unknown")"
  if [ ! "\${disk_fs_type}" = "ext4" ]; then
    mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-persistent-disk-1
  fi

  # mount data volume
  mkdir -p /mnt/palworld-data
  mount -t ext4 /dev/disk/by-id/google-persistent-disk-1 /mnt/palworld-data
  
  # query for metadata
  curl -fsSL -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/environment" > /env
  image="$(curl -fsSL -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/image")"

  # launch palworld server
  docker run --restart on-failure -p 8211:8211/udp -v /mnt/palworld-data:/data/palworld --env-file /env \${image}
  `;

  // create the server VM instance
  // NOTE: careful editing metadata - is fetched during startup
  // NOTE: careful editing tags - is used to define firewall rules
  const server = new gcp.compute.Instance(
    "palworld-server",
    {
      allowStoppingForUpdate: true,
      deletionProtection: false,
      machineType: "n1-highmem-2",
      attachedDisks: [{ source: dataDisk.id, mode: "READ_WRITE" }],
      bootDisk: {
        initializeParams: {
          image: "projects/debian-cloud/global/images/family/debian-11",
          size: 20,
        },
      },
      networkInterfaces: [
        {
          network: "default",
          accessConfigs: [{ natIp: ipAddress.address }],
        },
      ],
      metadataStartupScript: serverScript,
      metadata: {
        environment: Object.entries(settings)
          .map(([key, value]) => `${key}=${value}`)
          .join("\n"),
        image,
      },
      serviceAccount: {
        email: serviceAccount.email,
        scopes: [],
      },
      tags: ["palworld-server"],
    },
    { deleteBeforeReplace: true, provider, replaceOnChanges: ["metadata"] }
  );

  // create a firewall rule allowing game traffic into the VM
  const firewallRule = new gcp.compute.Firewall(
    "palworld-server-firewall-rule",
    {
      allows: [
        {
          ports: ["8211"],
          protocol: "udp",
        },
      ],
      network: "default",
      sourceRanges: ["0.0.0.0/0"],
      targetTags: ["palworld-server"],
    },
    { provider }
  );

  return {
    ipAddress: ipAddress.address,
    serviceAccount: serviceAccount.email,
    dataDisk: dataDisk.name,
    instance: server.name,
    settings,
    image,
    project,
    region,
  };
};
