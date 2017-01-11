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
#	@version		3.0.0
#	@build			9th January, 2017
#	@package		Exchange Rates <https://github.com/ExchangeRates>
#	@subpackage		Rate Factory
#	@author			Llewellyn van der Merwe <https://github.com/Llewellynvdm>
#	@copyright		Copyright (C) 2015. All Rights Reserved
#	@license		GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#
#/-----------------------------------------------------------------------------------------------------------------------------/

                                ##############################################################
                                ##############                                      ##########
                                ##############             FUNCTIONS                ##########
                                ##############                                      ##########
                                ##############################################################

# build the repo folders locally if not set already
function setLocalRepo () {
    # ensure repos is already set
    if [ ! -d "$1" ] 
    then
        mkdir -p "$1"
        cd "$REPO"
        local NAME=${3:-"$2"}
        # keep local repo small
        git clone --depth 1 "git@github.com:ExchangeRates/$2.git" "$NAME"
    fi
}

# remove a folder and all its content
function rmLocalRepo () {
    local FOLDER="$1"
    # ensure repos is removed
    if [ -d "$FOLDER" ] 
    then
        rm -fR "$FOLDER"
    fi
}

# simple basic random
function getRandom () {
    echo $(tr -dc 'A-HJ-NP-Za-km-z2-9' < /dev/urandom | dd bs=5 count=1 status=none)
}

# set the yahoo url and call the get date function
function get_YAHOO () {

    urlstart="https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20%28%22"
    urlend="%22%29&format=json&env=store://datatables.org/alltableswithkeys&callback="
    # get the data from yahoo
    get_YAHOO_DATA "$urlstart$1$urlend"
}

# getting the data from yahoo
function get_YAHOO_DATA () {

    json=$(wget -q -O- "$1")
    Ids=($( echo "$json" | jq -r '.query.results.rate[].id'))
    Names=($( echo "$json" | jq -r '.query.results.rate[].Name'))
    Rates=($( echo "$json" | jq -r '.query.results.rate[].Rate'))
    Bids=($( echo "$json" | jq -r '.query.results.rate[].Bid'))
    Asks=($( echo "$json" | jq -r '.query.results.rate[].Ask'))
    Dates=($( echo "$json" | jq -r '.query.results.rate[].Date'))
    Times=($( echo "$json" | jq -r '.query.results.rate[].Time'))
    for i in "${!Ids[@]}"; do
	nAAm=''
        # make sure we rest these
        if [[ -n "${Ids[$i]}" && "null" != "${Ids[$i]}" ]]
        then
            if [[ "${Ids[$i]}" != *"=X"* && "${Dates[$i]}" != *"N/A"* && "${Times[$i]}" != *"N/A"* && "${Rates[$i]}" != *"N/A"* ]]
            then
                set_YAHOO_DATA "${Names[$i]}" "${Ids[$i]}" "${Dates[$i]}" "${Times[$i]}" "${Rates[$i]}" "${Bids[$i]}" "${Asks[$i]}" & # to speed up the work
            fi
        fi
    done
}

# store the new data
function set_YAHOO_DATA () {

	# load the arguments
	NaMe=$(setName "$1" "$2")
	iDee="$2"
	DaTe="$3"
	TiMe=$(fixTime "$4")
	RaTe="$5"
	BiD="$6"
	AsK="$7"
	DaTe_stored=''
	TiMe_stored=''
	# give little heads-up to console
	echo "Now working with - $iDee"
	# check if update is due
	if (( "$oldBuilder" ==  1 ));
	then
		# get the old data
		lineFound=$(LC_ALL=C fgrep -n "$iDee" "$yahooBuilder")
		if (( ${#lineFound} > 3 ));
		then
			DaTe_stored=$(echo "$lineFound" | awk '{print $6}' )
			TiMe_stored=$(echo "$lineFound" | awk '{print $7}' )
			# fix the time issue
			TiMe_stored=$(fixTime "$TiMe_stored")
			# check update is due
			updateReady=$(checkStatus "$DaTe" "$TiMe" "$DaTe_stored" "$TiMe_stored")
			# check if update is due
			if (( "$updateReady" ==  1 ));
			then
				updateLine=$(echo "$lineFound" | awk -F : '{print $1}' )
				re='^[0-9]+$'
				if [[ $updateLine =~ $re ]] ;
				then
					# build data string for the file
					# name	idee	rate	bid	ask	date	time
					exchangeRateLine="$NaMe\t$iDee\t$RaTe\t$BiD\t$AsK\t$DaTe\t$TiMe"
					sed -i "${updateLine}s|.*|$exchangeRateLine|" "$yahooBuilder"
				fi
			fi
		else
			# build data string for the file
			# name	idee	rate	bid	ask	date	time
			exchangeRateLine="$NaMe\t$iDee\t$RaTe\t$BiD\t$AsK\t$DaTe\t$TiMe"
			echo -e "$exchangeRateLine" >> "$yahooBuilder"
		fi
	else
		# build data string for the file
		# name	idee	rate	bid	ask	date	time
		exchangeRateLine="$NaMe\t$iDee\t$RaTe\t$BiD\t$AsK\t$DaTe\t$TiMe"
		echo -e "$exchangeRateLine" >> "$builder"
	fi
}

function setName() {
	namE="$1"
	iDe="$2"
	slashString="/"
	if (( ${#namE} == 7 ));
	then
		if [[ "$namE" == *"$slashString"* ]]
       		then
			echo "$namE"
		else
			# return the ID as name
			var1=${iDe:0:3}
			var2=${iDe:3}
			echo "$var1/$var2"
		fi
	else
		# return the ID as name
		var1=${iDe:0:3}
		var2=${iDe:3}
		echo "$var1/$var2"
	fi
}

# make sure the data given is newer then what is in the repo
function fixTime () {
    # load args
    Tyd="$1"
    # load the arguments
    wrongTime00="00:"
    wrongTime0="0:"
    correctTime="12:"
    if [[ "$Tyd" != *"N/A"* ]]
    then
        # fix mid-nite issue
        if [[ "$Tyd" == "$wrongTime00"* ]]
        then
            Tyd="${Tyd/$wrongTime00/$correctTime}"
        fi
        # fix mid-nite issue
        if [[ "$Tyd" == "$wrongTime0"* ]]
        then
            Tyd="${Tyd/$wrongTime0/$correctTime}"
        fi
    fi
    echo "$Tyd"
}

# make sure the data given is newer then what is in the repo
function checkStatus () {
    # load args
    DaTte="$1"
    TiMme="$2"
    DaTte_stored="$3"
    TiMme_stored="$4"
    if [[ "$DaTte_stored" != *"N/A"* && "$TiMme_stored" != *"N/A"* ]]
    then
        # set the stored time stamp
        storedTime=$(TZ=":ZULU" date -d "$DaTte_stored $TiMme_stored" +"%s" )
        
        # set the new time stamp
        newTime=$(TZ=":ZULU" date -d "$DaTte $TiMme" +"%s" )

        # update only that new date found
        if (( "$newTime" > "$storedTime" ));
        then
            # switch to set update to true
            echo 1
	else
	    echo 0
        fi
    else
        # switch to set update to true
        echo 1
    fi
}

function setJsonRates () {

   # reset the file
   echo -e -n  "{" > "$ratesBuilder"
   # build data string for the file
   awk '{print "\""$2"\":{" "\"Name\":" "\""$1"\", " "\"id\":" "\""$2"\", " "\"Rate\":" "\""$3"\", " "\"Bid\":" "\""$4"\", " "\"AsK\":" "\""$5"\", " "\"Date\":" "\""$6"\", " "\"Time\":" "\""$7"\"}," }' "$yahooBuilder" >> "$ratesBuilder"
   # remove last coma and add closing brace  
   sed -i '$ s/,$/}/g' "$ratesBuilder"
}

# git function at end
function commitChanges () {
    cd "$1"
    git add .
    git commit -am "$2"
}

# set the commit messages
function getMessage () {
    if [[ "$action" == 'all' ]]
    then
        echo "$1 All Rates"
    elif [[ "$action" == 'main' ]]
    then
        echo "$1 Main Rates"
    elif [[ "$action" == 'updater' ]]
    then
        echo "$1 rates.json"
    else
        echo "$1"
    fi
}

function pushChanges () {
    git push origin master -f
}
