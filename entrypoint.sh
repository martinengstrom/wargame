#!/bin/bash

function setConfig() {
	ENV_VAR_NAME="$1"
	CONF_VAR_NAME="$2"
	FILENAME="$3"

	if [ ! -z "${ENV_VAR_NAME}" ]; then
		# Add quotes if its a string
		if [[ ! "$ENV_VAR_NAME" =~ ^-?[0-9]+$ ]]; then
			ENV_VAR_NAME="\"${ENV_VAR_NAME}\""
		fi

        	OUTP="$(sed "s/${CONF_VAR_NAME}\s*=\s*.*/${CONF_VAR_NAME} = ${ENV_VAR_NAME}/g" ${FILENAME})";
		echo "$OUTP" > "${FILENAME}";
	fi
}

function setInit() (
	setConfig "$1" "$2" "/home/wargame3_server/variables.ini"
)

function setAuth() (
	LOGIN_FILENAME="/home/wargame3_server/login.ini"
	setConfig "$1" "$2" "${LOGIN_FILENAME}"
)

function setAdmin() (
	FILENAME="/home/wargame3_server/admins.ini"
	grep -xq variables.ini -e "$1"
	if [ $? -eq 0 ]; then
		# Admin already exists
		sed "s/$1=.*/$1=\"abcdefghijklmnopqrstuvwxyz\"/g" ${FILENAME} > ${FILENAME};
	else
		# Does not exist, add
		echo "$1=\"abcdefghijklmnopqrstuvwxyz\"" >> ${FILENAME};
	fi	
)

# Set server auth stuff
setAuth "${EUG_USER}" login
setAuth "${EUG_PASS}" dedicated_key

# Set variables.ini where possible
setInit "${SERVER_NAME}" ServerName
setInit "${MAX_PLAYERS}" NbMaxPlayer
setInit "${GAME_TYPE}" GameType
setInit "${MAP}" Map
setInit "${STARTING_MONEY}" InitMoney
setInit "${SCORE_LIMIT}" ScoreLimit
setInit "${VICTORY_CONDITION}" VictoryCond
setInit "${MIN_PLAYERS}" NbMinPlayer
setInit "${MAX_DEBRIEF_TIME}" DebriefingTimeMax
setInit "${MAX_DEPLOY_TIME}" DeploiementTimeMax
setInit "${WARMUP_COUNTDOWN}" WarmupCountdown
setInit "${TIME_LIMIT}" TimeLimit
setInit "${DELTA_MAX_TEAM_SIZE}" DeltaMaxTeamSize
setInit "${MAX_TEAM_SIZE}" MaxTeamSize

# Add admin if available
if [ ! -z "${ADMIN_ID}" ]; then
	setAdmin "${ADMIN_ID}"
fi

# Run wargame server with the provided external arguments
/home/wargame3_server/wargame3-server $@
