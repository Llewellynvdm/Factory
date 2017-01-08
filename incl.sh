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
        # make sure we rest these
        updateCurrent=0
        updateHistory=0
        if [[ -n "${Ids[$i]}" && "null" != "${Ids[$i]}" ]]
        then
            if [[ "${Ids[$i]}" != *"=X"* && "${Dates[$i]}" != *"N/A"* && "${Times[$i]}" != *"N/A"* && "${Rates[$i]}" != *"N/A"* ]]
            then
                house_cleaning "${Names[$i]}" "${Ids[$i]}" "${Dates[$i]}" "${Times[$i]}" "${Rates[$i]}" "${Bids[$i]}" "${Asks[$i]}"
                # only update the new data given
                if (( updateCurrent == 1 ));
                then
                    echo -e "$exchangeRateJson" > "$current/$iDee.json"
                fi
                # only update the new data given
                if (( updateHistory == 1 ));
                then
                    echo -e "$exchangeRateJson" > "$historical/$iDee/$dateAsFileName.json"
                fi
            fi
        fi
    done
}

# set data to local file in repo
function setData () {

    local folder="$1"
    local target="$2"

    # load local data to full set if not new found
    updateLine4FullSet="\"$iDee_stored\":$json_one_line"
    # load to full set
    if [[ "${bothDataSets[$target]}" == "{" ]]
    then
        # first clear all data from file
        > "$folder/$target.json"
        bothDataSets["$target"]="{$updateLine4FullSet"
    else
        bothDataSets["$target"]=",\n$updateLine4FullSet"
    fi
    # now store next line
    echo -e -n "${bothDataSets[$target]}" >> "$folder/$target.json"
}

# get data from file in local repo
function getLocalData () {
    
    local file="$1"
    storedData=$(<"$file")
    
    if [ $# -eq 2 ]
    then
        # get the stored id and all lines from the file
        iDee_stored=($( echo "$storedData" | jq '.id' | tr -d \"))
        json_one_line=$( echo "$storedData" | tr -d '\040\011\012\015')
    else
        # get the stored time from the file
        DaTe_stored=($( echo "$storedData" | jq '.Date' | tr -d \"))
        TiMe_stored=($( echo "$storedData" | jq '.Time' | tr -d \"))
    fi
}


function closeDataSet () {

    local folder="$1"
    local target="$2"

    # now store closing line
    if [[ -n "${bothDataSets[$target]}" && "${bothDataSets[$target]}" != "{" ]]
    then
        bothDataSets["$target"]="}"
        echo -e -n "${bothDataSets[$target]}" >> "$folder/$target.json"
    fi
}

# main set all data
function setAll () {

    local filename
    local folder="$1"
    local All="$2"
    local AllVIP="$3"

    cd "$folder"
    for filename in *.json; do
        if [[ -n "$folder/$filename" && "$filename" != "$All.json" &&  "$filename" != "$AllVIP.json" ]]
        then
            getLocalData "$folder/$filename" "Updater"
            setData "$folder" "$All"
        fi
    done
    # now store last line
    closeDataSet "$folder" "$All"
}

function setVIP () {

    local folder="$1"
    local AllVIP="$2"
    # load main currencies for VIP
    readarray -t currencies < "$DIR/mainCurrencies"

    for currency1 in "${currencies[@]}" ; do
        for currency2 in "${currencies[@]}" ; do
            if [[ "$currency1" != "$currency2" && -n "$folder/$currency1$currency2.json" ]]
            then
                getLocalData "$folder/$currency1$currency2.json" "Updater"
                setData "$folder" "$AllVIP"
            fi
        done
    done
    # now store last line
    closeDataSet "$folder" "$AllVIP"
}

# do some house cleaning work
function house_cleaning () {
    # load the arguments
    NaMe="$1"
    iDee="$2"
    DaTe="$3"
    TiMe="$4"
    RaTe="$5"
    BiD="$6"
    AsK="$7"
    # give little heads-up to console
    echo "Now working with - $iDee"
    # set the file name
    dateAsFileName=$(date -d "$DaTe" +"%m-%d-%Y" )
    # build data string for the fiels
    exchangeRateJson="{\n\t\"Name\": \"$NaMe\",\n\t\"id\": \"$iDee\",\n\t\"Rate\": \"$RaTe\",\n\t\"Bid\": \"$BiD\",\n\t\"Ask\": \"$AsK\",\n\t\"Date\": \"$DaTe\",\n\t\"Time\": \"$TiMe\"\n}"
    # create the historical currency exchange directory only when it was not already created
    mkdir -p "$historical/$iDee"
    # check that current file exist
    if [[ -f "$current/$iDee.json" ]]
    then
        # get the local stored data
        getLocalData "$current/$iDee.json"
        # check the new data is newer then stored data
        check_if_update_ready Current
    else
        updateCurrent=1
    fi
    # check the historical file exist
    if [[ -f "$historical/$iDee/$dateAsFileName.json" ]]
    then
        # get the local stored data
        getLocalData "$historical/$iDee/$dateAsFileName.json"
        # check the new data is newer then stored data
        check_if_update_ready History
    else
        updateHistory=1
    fi
}

# set update switch
function set_update_ready () {
    # load the arguments
    typeData="$1"
    # switch to set update to true
    if [[ $typeData == Current ]]
    then
        updateCurrent=1
    fi
    # switch to set update to true
    if [[ $typeData == History ]]
    then
        updateHistory=1
    fi
}

# make sure the data given is newer then what is in the repo
function check_if_update_ready () {
    # load the arguments
    typeData="$1"
    wrongTime00="00:"
    wrongTime0="0:"
    correctTime="12:"
    if [[ "$DaTe_stored" != *"N/A"* && "$TiMe_stored" != *"N/A"* ]]
    then
        # fix mid-nite issue
        if [[ "$TiMe_stored" == "$wrongTime00"* ]]
        then
            TiMe_stored="${TiMe_stored/$wrongTime00/$correctTime}"
        fi
        # fix mid-nite issue
        if [[ "$TiMe_stored" == "$wrongTime0"* ]]
        then
            TiMe_stored="${TiMe_stored/$wrongTime0/$correctTime}"
        fi
        # set the stored time stamp
        storedTime=$(TZ=":ZULU" date -d "$DaTe_stored $TiMe_stored" +"%s" )
        # fix mid-nite issue
        if [[ "$TiMe" == "$wrongTime00"* ]]
        then
            TiMe="${TiMe/$wrongTime00/$correctTime}"
        fi
        # fix mid-nite issue
        if [[ "$TiMe" == "$wrongTime0"* ]]
        then
            TiMe="${TiMe/$wrongTime0/$correctTime}"
        fi
        # set the new time stamp
        newTime=$(TZ=":ZULU" date -d "$DaTe $TiMe" +"%s" )
        # update only that new date found
        if (( "$newTime" > "$storedTime" ));
        then
            # switch to set update to true
            set_update_ready "$typeData"
        fi
    else
        # switch to set update to true
        set_update_ready "$typeData"
    fi
}

#git functions at start up
function getGitHard () {
    OnMaster "$1"
    git fetch
    git gc
    git reset --hard origin/master
    git clean -f -d
}
function OnMaster () {
    cd "$1"
    git checkout master
}
function OnTmp () {
    cd "$1"
    git checkout tmpUpdate
}
function GoTmp () {
    cd "$1"
    git checkout -b tmpUpdate
}
function RmTmp () {
    cd "$1"
    git checkout master
    git branch -D tmpUpdate
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
        echo "$1 ALLRATES.json & ALLVIPRATES.json"
    else
        echo "$1"
    fi
}

function getFileDateMaster () {
    # get file date in master
    MasterFileChanged["$2"]=$(date +"%s" -r "$1/$2")
}

function getFileDateTmp () {
    # get file date in master
    TmpFileChanged["$2"]=$(date +"%s" -r "$1/$2")
    # now see that we should keep the update
    if (("${MasterFileChanged[$2]}"-gt"${TmpFileChanged[$2]}"));
    then
        git checkout master -- "$2"
    fi
}

# select what files should be cept
function selectFiles () {
    cd "$current"
    local fileList=($(git diff master tmpUpdate --name-only))
    local fileName_c
    local fileName_h
    OnMaster "$current"
    for fileName_c in "${fileList[@]}"; do
        getFileDateMaster "$current" "$fileName_c"
    done
    OnTmp "$current"
    for fileName_c in "${fileList[@]}"; do
        getFileDateTmp "$current" "$fileName_c"
    done
    # make sure all changes are committed
    git add .
    git commit --amend --no-edit --allow-empty
    cd "$historical"
    fileList=($(git diff master tmpUpdate --name-only))
    OnMaster "$historical"
    for fileName_h in "${fileList[@]}"; do
        getFileDateMaster "$historical" "$fileName_h"
    done
    OnTmp "$historical"
    for fileName_h in "${fileList[@]}"; do
        getFileDateTmp "$historical" "$fileName_h"
    done
    # make sure all changes are committed
    git add .
    git commit --amend --no-edit --allow-empty
}

function pushChanges () {
    git push origin master -f
}

function mergeChanges () {
    OnMaster "$1"
    git merge -X theirs -m "$2" tmpUpdate
    RmTmp "$1"
    pushChanges
}