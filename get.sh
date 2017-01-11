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
#	@version			3.0.0
#	@build			9th January, 2017
#	@package		Exchange Rates <https://github.com/ExchangeRates>
#	@subpackage		Rate Factory
#	@author			Llewellyn van der Merwe <https://github.com/Llewellynvdm>
#	@copyright		Copyright (C) 2015. All Rights Reserved
#	@license		GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#
#/-----------------------------------------------------------------------------------------------------------------------------/

#get start time
starrted=$(date +"%s" )

# get script path
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" || "$DIR" == '.' ]]; then DIR="$PWD"; fi

# load functions
. "$DIR/args.sh"
. "$DIR/incl.sh"

# we move out of the factory folder
cd "$DIR"
cd ../

# some global variables
oldBuilder=1
yahooTake=1
yahooTry=''

# get random folder name to avoid conflict
newFolder=$(getRandom)
# set this repo location
REPO="$PWD/T3MPR3P0_$newFolder"

# yahoo repo
yahoo="$REPO/yahoo"
setLocalRepo "$yahoo" "yahoo"

# builder file
builderFileName="builder.txt"
builder="$REPO/$builderFileName"
touch "$builder"

# current builder file
yahooBuilder="$yahoo/$builderFileName"

# check if file exist
if [ ! -f "$yahooBuilder" ] 
then
    oldBuilder=0
fi

# load currencies to check for
CurName="Currencies"
readarray -t currencies < "$DIR/$action$CurName"

# use UTC+00:00 time also called zulu
Datetimenow=$(TZ=":ZULU" date +"%m/%d/%Y @ %R (UTC)" )
echo "Started: $Datetimenow"

## LOAD MAIN ##
. "$DIR/main.sh"

# use UTC+00:00 time also called zulu
DateTimeCommit=$(TZ=":ZULU" date +"%m/%d/%Y @ %R (UTC)" )

# move the file into place if it was not found
if (( "$oldBuilder" ==  0 ));
then
	mv -f "$builder" "$yahooBuilder"
fi

# rates file
ratesFileName="rates.json"
ratesBuilder="$yahoo/$ratesFileName"

# check if file exist
if [ ! -f "$ratesBuilder" ] 
then
    touch "$ratesBuilder"
fi

# load all the rates to json (run updater)
setJsonRates

# push to repo
commitMessage=$(getMessage "Updated")
commitChanges "$yahoo" "$commitMessage $DateTimeCommit"
pushChanges

# remove local repos to keep it small
rmLocalRepo "$REPO"

ennded=$(date +"%s" )
jobTime=$((ennded-starrted))
echo "Full Update took $jobTime seconds ($DateTimeCommit)"
