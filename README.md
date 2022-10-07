# crtsh-recon
A script that accepts wildcard domains via STD-IN or command-line arguments, scrapes crt.sh for unique subdomains, and outputs the scraped subs to STD-OUT.

## Script functionality
1. verify dependencies
2. Collect and store list of wildcard domains passed to the script 
   via STD-IN or command-line arguments.
3. enter while loop
   1) Query crt.sh, parse the json, and remove duplicate results
   2) Add unique domains to array
   3) repeat until all wildcard domains have been utilized and then exit the loop.
4. print array of scraped subdomains to STD-OUT

## Usage:

`cat ./wildcards | ./crtsh-recon.sh | tee crtsh-output.txt`
OR
`./crtsh-recon.sh tesla.com tesla.cn teslamotors.com | tee crtsh-output.txt`

## Disclaimer:

This script was written for the purpose of performing recon on bug bounty programs. 
Do not use this script for illegal/unauthorized security testing.
