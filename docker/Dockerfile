FROM cm2network/steamcmd:latest AS download

# this environment variable primarily busts the docker layer cache 
ENV PALWORLD_VERSION=0.1.3.0

RUN \
    # make steamclient.so symlinks portable
    rm -rf /home/steam/.steam/sdk32/steamclient.so /home/steam/.steam/sdk64/steamclient.so \
    && ln -s ../../steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so \
    && ln -s ../../steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so \
    # install palworld dedicated server
    && /home/steam/steamcmd/steamcmd.sh +login anonymous +app_update 2394010 validate +quit 

FROM ubuntu:jammy AS server
RUN \
    apt -y update \
    && apt -y install \ 
        vim \
        # gosu steps down to the 'palworld' user in the entrypoint
        gosu \
        # install palworld dependencies
        xdg-user-dirs \
    # create 'palworld' user (the server requires a non-root user)
    && useradd palworld --create-home

# copy palworld server from 'download' stage.
COPY --chown=palworld:palworld --from=download /home/steam/Steam /home/palworld/Steam
COPY --chown=palworld:palworld --from=download /home/steam/steamcmd /home/palworld/steamcmd
COPY --chown=palworld:palworld --from=download /home/steam/.steam /home/palworld/.steam

# store palworld location in environment
ENV PALWORLD_HOME=/home/palworld/Steam/steamapps/common/PalServer

# copy local files
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# represent palworld settings as environment variables
ENV PALWORLD_B_ACTIVE_UNKO="False"
ENV PALWORLD_B_AUTO_RESET_GUILD_NO_ONLINE_PLAYERS="False"
ENV PALWORLD_B_CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP="False"
ENV PALWORLD_B_ENABLE_AIM_ASSIST_KEYBOARD="False"
ENV PALWORLD_B_ENABLE_AIM_ASSIST_PAD="True"
ENV PALWORLD_B_ENABLE_DEFENSE_OTHER_GUILD_PLAYER="False"
ENV PALWORLD_B_ENABLE_NON_LOGIN_PENALTY="True"
ENV PALWORLD_B_ENABLE_PLAYER_TO_PLAYER_DAMAGE="False"
ENV PALWORLD_B_ENABLE_FAST_TRAVEL="True"
ENV PALWORLD_B_ENABLE_FRIENDLY_FIRE="False"
ENV PALWORLD_B_ENABLE_INVADER_ENEMY="True"
ENV PALWORLD_B_EXIST_PLAYER_AFTER_LOGOUT="False"
ENV PALWORLD_B_IS_MULTIPLAY="False"
ENV PALWORLD_B_IS_PVP="False"
ENV PALWORLD_B_IS_START_LOCATION_SELECT_BY_MAP="True"
ENV PALWORLD_B_USE_AUTH="True"
ENV PALWORLD_ADMIN_PASSWORD=""
ENV PALWORLD_AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS="72.000000"
ENV PALWORLD_BAN_LIST_URL="https://api.palworldgame.com/api/banlist.txt"
ENV PALWORLD_BASE_CAMP_MAX_NUM="128"
ENV PALWORLD_BASE_CAMP_WORKER_MAX_NUM="15"
ENV PALWORLD_BUILD_OBJECT_DAMAGE_RATE="1.000000"
ENV PALWORLD_BUILD_OBJECT_DETERIORATION_DAMAGE_RATE="1.000000"
ENV PALWORLD_CAPTURE_RATE="1.000000"
ENV PALWORLD_COLLECTION_DROP_RATE="1.000000"
ENV PALWORLD_COLLECTION_OBJECT_HP_RATE="1.000000"
ENV PALWORLD_COLLECTION_OBJECT_RESPAWN_SPEED_RATE="1.000000"
ENV PALWORLD_COOP_PLAYER_MAX_NUM="4"
ENV PALWORLD_DAY_TIME_SPEED_RATE="1.000000"
ENV PALWORLD_DEATH_PENALTY="All"
ENV PALWORLD_DIFFICULTY="None"
ENV PALWORLD_DROP_ITEM_ALIVE_MAX_HOURS="1.000000"
ENV PALWORLD_DROP_ITEM_MAX_NUM="3000"
ENV PALWORLD_DROP_ITEM_MAX_NUM_UNKO="100"
ENV PALWORLD_ENEMY_DROP_ITEM_RATE="1.000000"
ENV PALWORLD_EXP_RATE="1.000000"
ENV PALWORLD_GUILD_PLAYER_MAX_NUM="20"
ENV PALWORLD_NIGHT_TIME_SPEED_RATE="1.000000"
ENV PALWORLD_PAL_AUTO_HP_REGENE_RATE="1.000000"
ENV PALWORLD_PAL_AUTO_HP_REGENE_RATE_IN_SLEEP="1.000000"
ENV PALWORLD_PAL_DAMAGE_RATE_ATTACK="1.000000"
ENV PALWORLD_PAL_DAMAGE_RATE_DEFENSE="1.000000"
ENV PALWORLD_PAL_EGG_DEFAULT_HATCHING_TIME="72.000000"
ENV PALWORLD_PAL_SPAWN_NUM_RATE="1.000000"
ENV PALWORLD_PAL_STAMINA_DECREACE_RATE="1.000000"
ENV PALWORLD_PAL_STOMACH_DECREACE_RATE="1.000000"
ENV PALWORLD_PLAYER_AUTO_HP_REGENE_RATE="1.000000"
ENV PALWORLD_PLAYER_AUTO_HP_REGENE_RATE_IN_SLEEP="1.000000"
ENV PALWORLD_PLAYER_DAMAGE_RATE_ATTACK="1.000000"
ENV PALWORLD_PLAYER_DAMAGE_RATE_DEFENSE="1.000000"
ENV PALWORLD_PLAYER_STAMINA_DECREACE_RATE="1.000000"
ENV PALWORLD_PLAYER_STOMACH_DECREACE_RATE="1.000000"
ENV PALWORLD_PUBLIC_IP=""
ENV PALWORLD_PUBLIC_PORT="8211"
ENV PALWORLD_REGION=""
ENV PALWORLD_RCON_ENABLED="False"
ENV PALWORLD_RCON_PORT="25575"
ENV PALWORLD_SERVER_PLAYER_MAX_NUM="32"
ENV PALWORLD_SERVER_DESCRIPTION=""
ENV PALWORLD_SERVER_NAME="Default Palworld Server"
ENV PALWORLD_SERVER_PASSWORD=""
ENV PALWORLD_WORK_SPEED_RATE="1.000000"

EXPOSE 8211
EXPOSE 25575
WORKDIR "${PALWORLD_HOME}"

ENTRYPOINT ["/entrypoint.sh"]
