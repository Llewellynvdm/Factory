#!/bin/bash
#/--------------------------------------------------------------------------------------------------------|  www.vdm.io  |------/
#    __      __       _     _____                 _                                  _     __  __      _   _               _
#    \ \    / /      | |   |  __ \               | |                                | |   |  \/  |    | | | |             | |
#     \ \  / /_ _ ___| |_  | |  | | _____   _____| | ___  _ __  _ __ ___   ___ _ __ | |_  | \  / | ___| |_| |__   ___   __| |
#      \ \/ / _` / __| __| | |  | |/ _ \ \ / / _ \ |/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __| | |\/| |/ _ \ __| '_ \ / _ \ / _` |
#       \  / (_| \__ \ |_  | |__| |  __/\ V /  __/ | (_) | |_) | | | | | |  __/ | | | |_  | |  | |  __/ |_| | | | (_) | (_| |
#        \/ \__,_|___/\__| |_____/ \___| \_/ \___|_|\___/| .__/|_| |_| |_|\___|_| |_|\__| |_|  |_|\___|\__|_| |_|\___/ \__,_|
#                                                        | |
#                                                        |_|
#/-------------------------------------------------------------------------------------------------------------------------------/
#
#	@version		2.0.1
#	@build			4th July, 2016
#	@package		Exchange Rates VIP <https://github.com/ExchangeRates>
#	@subpackage		Rate Factory
#	@author			Llewellyn van der Merwe <https://github.com/Llewellynvdm>
#	@copyright		Copyright (C) 2015. All Rights Reserved
#	@license		GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#
#/-----------------------------------------------------------------------------------------------------------------------------/

#get start time
started=$(date +"%s" )

# get script path
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" || "$DIR" == '.' ]]; then DIR="$PWD"; fi
# load functions
. "$DIR/incl.sh"

# we move out of the factory folder
cd "$DIR"
cd ../

# get random folder name to avoid conflict
newFolder=$(getRandom)
# set this repo location
REPO="$PWD/T3MPR3P0_$newFolder"

# path to local repo
folder="$REPO/Updater"
setLocalRepo  "$folder" "Current" "Updater"

# set some defaults
iDee_stored=''
json_one_line=''
All="ALLRATES"
AllVIP="ALLVIPRATES"
declare -A bothDataSets
bothDataSets["$All"]="{"
bothDataSets["$AllVIP"]="{"

### MAIN ALL && MAIN VIP ###
setAll "$folder" "$All" "$AllVIP"   & VDMIO=$!
setVIP "$folder" "$AllVIP"          & VDMBZ=$!
wait $VDMIO
wait $VDMBZ
# do the git work
Datetimenow=$(TZ=":ZULU" date +"%m/%d/%Y @ %R (UTC)" )
git fetch
git add .
git commit -am "Updated ALLRATES.json and ALLVIPRATES.json $Datetimenow"
# TODO may collide with remote repo
git merge origin/master
pushChanges
# remove local repo to keep it small
rmLocalRepo "$REPO"
ended=$(date +"%s")
jobTime=$((ended-started))
echo "ALLRATES Update took seconds $jobTime ($Datetimenow)"