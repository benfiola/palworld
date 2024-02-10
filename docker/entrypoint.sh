#!/usr/bin/env sh
set -e

if [ "$(id -u)" = "0" ]; then
    echo "root entrypoint"

    # docker bind mounts do not work well with non-root users (which palworld requires)
    # if 'UID' or 'GID' is provided - this indicates that the palworld user should
    # use the uid/gid of the host user to enable bind mounts to function correctly
    if [ ! "$UID" = "" ]; then
        echo "setting palworld user uid"
        usermod -u "${UID}" palworld
    fi
    if [ ! "$GID" = "" ]; then
        echo "setting palworld user gid"
        groupmod -g "${GID}" palworld
    fi

    echo "creating palworld data"
    mkdir -p /data/palworld
    echo "ensuring palworld data owned by palworld user"
    chown -R palworld:palworld /data/palworld
    echo "symlinking palworld data into palworld home"
    rm -f "${PALWORLD_HOME}/Pal/Saved"
    ln -s /data/palworld "${PALWORLD_HOME}/Pal/Saved"
    if [ -f /data/palworld/Config/LinuxServer/PalWorldSettings.ini ]; then
        echo "backing up existing palworld data settings"
        backup_date="$(date +"%Y%m%d_%H%M%S")"
        cp /data/palworld/Config/LinuxServer/PalWorldSettings.ini "/data/palworld/Config/LinuxServer/PalWorldSettings.ini.${backup_date}"
    fi

    # build settings file from known environment variables
    # TODO: do a better job of scripting this
    mkdir -p /data/palworld/Config/LinuxServer/
    printf "[/Script/Pal.PalGameWorldSettings]\nOptionSettings=(" > /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "AdminPassword=\"${PALWORLD_ADMIN_PASSWORD}\"," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "AutoResetGuildTimeNoOnlinePlayers=${PALWORLD_AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bActiveUNKO=${PALWORLD_B_ACTIVE_UNKO}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bAutoResetGuildNoOnlinePlayers=${PALWORLD_B_AUTO_RESET_GUILD_NO_ONLINE_PLAYERS}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bCanPickupOtherGuildDeathPenaltyDrop=${PALWORLD_B_CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bEnableAimAssistPad=${PALWORLD_B_ENABLE_AIM_ASSIST_PAD}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bEnableAimAssistKeyboard=${PALWORLD_B_ENABLE_AIM_ASSIST_KEYBOARD}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bEnableDefenseOtherGuildPlayer=${PALWORLD_B_ENABLE_DEFENSE_OTHER_GUILD_PLAYER}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bEnableFastTravel=${PALWORLD_B_ENABLE_FAST_TRAVEL}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bEnableFriendlyFire=${PALWORLD_B_ENABLE_FRIENDLY_FIRE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bEnableInvaderEnemy=${PALWORLD_B_ENABLE_INVADER_ENEMY}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bEnableNonLoginPenalty=${PALWORLD_B_ENABLE_NON_LOGIN_PENALTY}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bEnablePlayerToPlayerDamage=${PALWORLD_B_ENABLE_PLAYER_TO_PLAYER_DAMAGE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bExistPlayerAfterLogout=${PALWORLD_B_EXIST_PLAYER_AFTER_LOGOUT}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bIsMultiplay=${PALWORLD_B_IS_MULTIPLAY}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bIsPvP=${PALWORLD_B_IS_PVP}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bIsStartLocationSelectByMap=${PALWORLD_B_IS_START_LOCATION_SELECT_BY_MAP}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "bUseAuth=${PALWORLD_B_USE_AUTH}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "BanListURL=\"${PALWORLD_BAN_LIST_URL}\"," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "BaseCampMaxNum=${PALWORLD_BASE_CAMP_MAX_NUM}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "BaseCampWorkerMaxNum=${PALWORLD_BASE_CAMP_WORKER_MAX_NUM}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "BuildObjectDamageRate=${PALWORLD_BUILD_OBJECT_DAMAGE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "BuildObjectDeteriorationDamageRate=${PALWORLD_BUILD_OBJECT_DETERIORATION_DAMAGE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "CollectionDropRate=${PALWORLD_COLLECTION_DROP_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "CollectionObjectHpRate=${PALWORLD_COLLECTION_OBJECT_HP_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "CollectionObjectRespawnSpeedRate=${PALWORLD_COLLECTION_OBJECT_RESPAWN_SPEED_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "CoopPlayerMaxNum=${PALWORLD_COOP_PLAYER_MAX_NUM}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "DayTimeSpeedRate=${PALWORLD_DAY_TIME_SPEED_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "DeathPenalty=${PALWORLD_DEATH_PENALTY}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "Difficulty=${PALWORLD_DIFFICULTY}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "DropItemAliveMaxHours=${PALWORLD_DROP_ITEM_ALIVE_MAX_HOURS}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "DropItemMaxNum=${PALWORLD_DROP_ITEM_MAX_NUM}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "DropItemMaxNum_UNKO=${PALWORLD_DROP_ITEM_MAX_NUM_UNKO}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "EnemyDropItemRate=${PALWORLD_ENEMY_DROP_ITEM_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "ExpRate=${PALWORLD_EXP_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "GuildPlayerMaxNum=${PALWORLD_GUILD_PLAYER_MAX_NUM}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "NightTimeSpeedRate=${PALWORLD_NIGHT_TIME_SPEED_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalAutoHPRegeneRate=${PALWORLD_PAL_AUTO_HP_REGENE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalAutoHpRegeneRateInSleep=${PALWORLD_PAL_AUTO_HP_REGENE_RATE_IN_SLEEP}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalCaptureRate=${PALWORLD_CAPTURE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalDamageRateAttack=${PALWORLD_PAL_DAMAGE_RATE_ATTACK}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalDamageRateDefense=${PALWORLD_PAL_DAMAGE_RATE_DEFENSE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalEggDefaultHatchingTime=${PALWORLD_PAL_EGG_DEFAULT_HATCHING_TIME}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalSpawnNumRate=${PALWORLD_PAL_SPAWN_NUM_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalStaminaDecreaceRate=${PALWORLD_PAL_STAMINA_DECREACE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PalStomachDecreaceRate=${PALWORLD_PAL_STOMACH_DECREACE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PlayerAutoHPRegeneRate=${PALWORLD_PLAYER_AUTO_HP_REGENE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PlayerAutoHpRegeneRateInSleep=${PALWORLD_PLAYER_AUTO_HP_REGENE_RATE_IN_SLEEP}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PlayerDamageRateAttack=${PALWORLD_PLAYER_DAMAGE_RATE_ATTACK}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PlayerDamageRateDefense=${PALWORLD_PLAYER_DAMAGE_RATE_DEFENSE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PlayerStaminaDecreaceRate=${PALWORLD_PLAYER_STAMINA_DECREACE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PlayerStomachDecreaceRate=${PALWORLD_PLAYER_STOMACH_DECREACE_RATE}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PublicIP=\"${PALWORLD_PUBLIC_IP}\"," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "PublicPort=${PALWORLD_PUBLIC_PORT}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "RCONPort=${PALWORLD_RCON_PORT}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "RCONEnabled=${PALWORLD_RCON_ENABLED}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "Region=\"${PALWORLD_REGION}\"," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "ServerDescription=\"${PALWORLD_SERVER_DESCRIPTION}\"," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "ServerName=\"${PALWORLD_SERVER_NAME}\"," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "ServerPassword=\"${PALWORLD_SERVER_PASSWORD}\"," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf "ServerPlayerMaxNum=${PALWORLD_SERVER_PLAYER_MAX_NUM}," >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    # NOTE: last item does not have comma
    printf "WorkSpeedRate=${PALWORLD_WORK_SPEED_RATE}" >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini
    printf ")" >> /data/palworld/Config/LinuxServer/PalWorldSettings.ini

    echo "relaunching entrypoint as palworld user"
    gosu palworld /entrypoint.sh "$@"
else
    echo "palworld entrypoint"

    if [ "$*" = "" ]; then
        echo "launching palworld server"
        "${PALWORLD_HOME}/PalServer.sh"
    else
        echo "running command: $*"
        "$@"
    fi
fi
