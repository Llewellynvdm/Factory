# Exchange Rates Factory
The Bash scripts used to update these repositories

## The Get Method (get.sh)
Exchange Rates Factory method to get is a **BASH** script that clones these ferious [github] (https://github.com/ExchangeRates) repos in the smallest way possible to the server on which it runs, it then gets the latest exchange rates from Yahoo and update the local json records in the cloned repositories.

Once it is finished it will merge and pushes to this [github] (https://github.com/ExchangeRates) remote repository to insure that it is always up-to-date with the latest exchange rates from Yahoo. It will then remove the local cloned repo from the server to insure that the local data is minimal (due to git scalability issues).

This can be done from multiple servers, since the script before it merges makes sure that any new changes made to the remote repositories are kept and not overwritten but this update since it takes about 20-30 minutes to update the 24000+ records.

## The Updater Method (updater.sh)
Exchange Rates Factory method to update is a **BASH** script that clones these [current github] (https://github.com/ExchangeRates/Current) repo in the smallest way possible to the server on which it runs, it then parses all the exchange rates in it and builds two files called ALLRATES.json & ALLVIPRATES.json with these lates exchange rates, it takes only around 2-3 minutes to run.

**It's all written in BASH scripting language and only needs [jq] (https://stedolan.github.io/jq/).**

## Why use this script?
We have found that Yahoo is not always consistently giving the latest exchange rates in their system. We picked this up when we started tracking the data with git. So we found new exchange rates being replaced with old exchange rates.

__So we wrote a bash script that queries Yahoo's finance xchange and only use values that are new.__

But instead of doing this on all our systems (in every application) we chose to use BASH, GIT and GITHUB to manage this data for us, so our queries to Yahoo is less and we are always sure we have the latest rates available from Yahoo.

## Features

* Cross platform
* Fast and effective updates
* Ability to retrieve all exchange rates in seconds from ALLRATES.json
* Historical records
* Central data sets
* Recourse friendly
* Free to all

## Getting started

First, clone the repository using git:

```bash
git clone git@github.com:ExchangeRates/Factory.git
```

Then give the execution permission to these scripts:

```bash
 $chmod +x get.sh
 $chmod +x updater.sh
```

## Usage GET

The syntax is quite simple:

```
 $./get.sh <PARAMETERS>

<%%>: Required param
```

**Required parameters:**  
* **all**  
will get all exchange rates 

* **main**  
will only get only main/VIP exchange rates


**Examples:**
```bash
    ./get.sh all
    ./get.sh main
```

## Usage UPDATER

```
 $./updater.sh
```

## Tested Environments

* GNU Linux

If you have successfully tested this script on others systems or platforms please let me know!

## Running as cron job
more info soon....
   
## BASH and JQ installation

**Debian & Ubuntu Linux:**
```bash
    sudo apt-get install bash (Probably BASH is already installed on your system)
    sudo apt-get install jq
```

## Donations

 If you want to support this project, please consider donating:
 * PayPal: pay@vdm.io
 * Bitcoin: 3H35PYwikEosvcjxHXGPLS1GufZ4b4iFu3
