FROM ubuntu:jammy

# update package manager
RUN apt -y update

# install vim
RUN apt -y install vim

# install pulumi
RUN apt -y install \
        curl \
    && curl -fsSL https://get.pulumi.com | sh
ENV PATH="/root/.pulumi/bin:${PATH}"

# install gcloud
RUN apt -y install \
        curl \
        apt-transport-https \
        ca-certificates \
        gnupg \
        sudo \   
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt -y update \
    && apt-get install google-cloud-cli

# install asdf
RUN apt -y install \
        curl \
        git \
    && git clone https://github.com/asdf-vm/asdf.git /root/.asdf --branch v0.14.0 \
    && echo ". \"/root/.asdf/asdf.sh\"" >> ~/.bashrc

ENV ASDF_DIR="/root/.asdf"

# install nodejs
RUN . "${ASDF_DIR}/asdf.sh" \
    && asdf plugin add nodejs \
    && asdf install nodejs 20.11.0 \
    && asdf global nodejs 20.11.0 \
    && asdf reshim