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

# check and set arguments
errorNote=$'################################################################################################# \n'
errorNote+=$'#                                                                                               # \n'
errorNote+=$'#    invalid argument please pass only one argument to set the get type ( all or main )         # \n'
errorNote+=$'#    all   = will get all exchange rates                                                        # \n'
errorNote+=$'#    main  = will only get only main/VIP exchange rates                                         # \n'
errorNote+=$'#                                                                                               # \n'
errorNote+=$'#################################################################################################'
if [ $# -eq 1 ] 
then
    # check input make lower case
    action=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    if [[ "$action" != 'all' && "$action" != 'main' ]]
    then
        echo "$errorNote"
        exit 1
    fi
else
    echo "$errorNote"
    exit 1
fi