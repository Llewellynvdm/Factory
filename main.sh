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


### MAIN ###
for currency1 in "${currencies[@]}" ; do
    for currency2 in "${currencies[@]}" ; do
        if [[ "$currency1" != "$currency2" ]]
        then
            if (( "$yahooTake" > 80 ));
            then
                get_YAHOO "$yahooTry"
                yahooTake=1
                yahooTry=''
            fi
            if (( "$yahooTake" ==  1 ));
            then
                yahooTry="$currency1$currency2"
            else
                yahooTry+="%22,%22$currency1$currency2"
            fi
            let "yahooTake++"
        fi
    done
done

# insure the all was fetched
if [[ -n "$yahooTry" ]]
then
    get_YAHOO "$yahooTry"
fi
