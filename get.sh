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
#	@package		Exchange Rates <https://github.com/ExchangeRates>
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
. "$DIR/args.sh"
. "$DIR/incl.sh"

# we move out of this repo
cd "$DIR"
cd ../
REPO="$PWD/VDM_T3MP_R3P0"

# current repo
current="$REPO/Current"
setLocalRepo "$current" "Current"

# historical repo
historical="$REPO/Historical"
setLocalRepo "$historical" "Historical"

# load currencies to check for
CurName="Currencies"
readarray -t currencies < "$DIR/$action$CurName"

# use UTC+00:00 time also called zulu
Datetimenow=$(TZ=":ZULU" date +"%m/%d/%Y @ %R (UTC)" )
echo "Started: $Datetimenow"

# some global variables
yahooTake=1
updateCurrent=0
updateHistory=0
yahooTry=''
json=''
dateAsFileName=''
exchangeRateJson=''
declare -A MasterFileChanged
declare -A TmpFileChanged
iDee=''
DaTe=''
TiMe=''
RaTe=''
BiD=''
AsK=''
DaTe_stored=''
TiMe_stored=''

# do some git upDates on current data
cd "$current"
GoTmp "$current"
# do some git upDates on historical data
cd "$historical"
GoTmp "$historical"

## LOAD MAIN ##
. "$DIR/main.sh"

# commit the changes to the tmp branch
commitChanges "$current"
commitChanges "$historical"

# get the latest updates
getGitHard "$current"
getGitHard "$historical"

# sort what files to keep
selectFiles

# merge the repos and push to remote
mergeChanges "$current"
mergeChanges "$historical"

# remove local repos to keep it small
rmLocalRepo "$current"
rmLocalRepo "$historical"

ended=$(date +"%s" )
jobTime=$((ended-started))
echo "Base Update took seconds $jobTime ($Datetimenow)"