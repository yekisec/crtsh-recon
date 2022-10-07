#!/bin/bash

################################################################################
## Name: crtsh-recon
## Author: Kyle Walters (yekisec) 
## License: GNU - General Public License (GPL)
##
## Functionality: 
##
## - This script takes a wildcard domain as input and outputs unique subdomains
## identified via https://crt.sh.
## 	
## - One or more wildcard domains can be provided through STD-IN or 
## command line arguments (separated by a single space.
################################################################################


# 1. verify dependencies
# 2. Collect and store list of wildcard domains passed to the script 
#    via STD-IN or command-line arguments.
# 3. enter while loop
#    1) Query crt.sh, parse the json, and remove duplicate results
#    2) Add unique domains to array
#    3) repeat until all wildcard domains have been utilized and then exit the loop.
# 4. print array of scraped subdomains to STD-OUT


MISSING_DEPENDENCY=5 # exit code 5 indicates a missing dependency
DEPENDENCIES="curl jq sed"

prog_exists () {
	if ! command -v $1 &> /dev/null
	then
		echo "0"
	else
		echo "1"
	fi
}

for DEPENDENCY in $DEPENDENCIES; do
	if [[ $(prog_exists $DEPENDENCY) -eq 0 ]] # prog_exists returns 0 if command not found.
	then
		printf "ERROR: the command \"$DEPENDENCY\" could not be located in the \$PATH\n"
		exit $MISSING_DEPENDENCY
	fi
done


IFS=$'\n'
if [[ ! $# -ge 1 ]]
then
	WILDCARD_DOMAINS=$(</dev/stdin)
else
	WILDCARD_DOMAINS="$*"
fi
RESULTS=""
for WILDCARD_DOMAIN in $WILDCARD_DOMAINS; do
	RESULTS+=$(curl -s "https://crt.sh/?q=%25.$WILDCARD_DOMAIN&output=json" | jq .[].common_name | sed "s/\"//g" | grep "\.$WILDCARD_DOMAIN$" | sed "s/^\*\.//g" | sort -u)

done

echo $RESULTS | tr " " "\n"
