#!/bin/bash
# private-ip-map.sh
# 12/18/2015 by tedr@tracesecurity.com
# Script to scan private IP ranges to identify ranges or subnets in use.


# Nmap host discovery scan settings.
# "nmap [range] [varNmapOpts] -oG - | [awk for first 3 octets of IP ]
# Original value was "-sn -n"
varNmapOpts="-sn -n"


varTempRandom=$(( ( RANDOM % 9999 ) + 1 ))
varTempFile1="temp-rf1-$varTempRandom.txt"
if [ -f "$varTempFile1" ]; then rm $varTempFile1; fi
varDateCreated="12/18/2015"
varDateLastMod="12/18/2015"
varOutFile="throwerror"
varHosts="1-4,100-104,250-254"
varNets="10,172,192"
varQuiet="N"

# Function for providing help/usage text
function usage
{
  echo
  echo "==========[ range-finder.sh by tedr@tracesecurity.com ]=========="
  echo
  echo "This script uses Nmap to scan a sample of hosts in each IANA"
  echo "private IP address range or subnet."
  echo
  echo "This can be used to identify which subnets or ranges are in use."
  echo
  echo "============================[ usage ]============================"
  echo
  echo "./range-finder.sh [options] -o [output file]"
  echo
  echo "-o [file]         Your output file and file name. Must not exist."
  echo
  echo "--hosts [value]   Specify the hosts in each subnet to be scanned."
  echo "                  The default is: 1-4,100-104,250-254"
  echo "                  This sets the last octet of the target ranges."
  echo "                  Ex: 10.0-255.0-255.[value]."
  echo
  echo "--nets [value]    Specify the networks to be scanned."
  echo "                  The default is: 10,172,192"
  echo "                  Ex: --nets 10,172 = 10.0.0.0/8 & 172.16.0.0/12"
  echo
  echo "-q                Quiet. Skip pause for confirmation at start."
  echo
  echo "Ex: ./range-finder.sh --nets 10,192 --hosts 1,254 -o out.txt"
  echo " -10.0.0.0/8 and 192.168.0.0/16 will be the target networks."
  echo " -.1 and .254 will be the only hosts on each network scanned."
  echo " -Output will be written to out.txt."
  echo
  echo "============================[ notes ]============================"
  echo
  echo "-The script will use the standard -sn host discovery option. You"
  echo " can change this by modifying the varNmapOpts value at the start"
  echo " of the script file."
  echo  
  echo "-Created $varDateCreated, last modified $varDateLastMod."
  echo
  exit
}

while [ "$1" != "" ]; do
  case $1 in
    --hosts ) shift
         if [ "$1" != "" ]; then varHosts="$1"; fi
         ;;
   --nets ) shift
         if [ "$1" != "" ]; then varNets="$1"; fi
         ;;
    -o ) shift
         varOutFile=$1
         if [ "$varOutFile" = "" ]; then varOutFile="throwerror"; fi # Flag for error if no file name was given
         if [ -f "$varOutFile" ]; then varOutFile="exists"; fi # Flag for error if output file exists
         ;;
    -q ) varQuiet="Y"
         ;;
    -h ) usage
         exit
         ;;
    * )  usage
         exit 1
  esac
  shift
done

if [ "$varOutFile" = "throwerror" ]; then echo "Error: No output file name supplied."; usage; fi
if [ "$varOutFile" = "exists" ]; then echo "Error: Output file exists."; usage; fi

varDo10=$(echo "$varNets" | grep 10)
varDo172=$(echo "$varNets" | grep 172)
varDo192=$(echo "$varNets" | grep 192)

echo
echo "==========[ range-finder.sh by tedr@tracesecurity.com ]=========="
echo
# Confirm info
echo "Networks to scan:"
if [ "$varDo10" != "" ]; then echo "10.0-255.0-255.x"; fi
if [ "$varDo172" != "" ]; then echo "172.16-31.0-255.x"; fi
if [ "$varDo192" != "" ]; then echo "192.168.0-255.x"; fi
echo
echo "Hosts to scan on each network:"
echo "$varHosts"
echo
echo "Command:"
echo "nmap [range] $varNmapOpts"
echo
echo "Output file:"
echo "$varOutFile"
echo
if [ "$varQuiet" = "N" ]; then read -p "Press enter to begin..."; echo; fi
echo "=============================[ run ]============================="
echo
# Start scanning
varTimeStart=$(date)
echo "Start: $varTimeStart"
if [ "$varDo10" != "" ]; then
  echo -n "Starting 10.0-255.0-255.x..."
  nmap 10.0-255.0-255.$varHosts $varNmapOpts -oG - | awk '/Up/{print $2}' | awk -F "." '{print $1 "." $2 "." $3 ".0-255"}' >> $varTempFile1
  echo " Done."
fi
if [ "$varDo172" != "" ]; then
  echo -n "Starting 172.16-31.0-255.x..."
  nmap 172.16-31.0-255.$varHosts $varNmapOpts -oG - | awk '/Up/{print $2}' | awk -F "." '{print $1 "." $2 "." $3 ".0-255"}' >> $varTempFile1
  echo " Done."
fi
if [ "$varDo192" != "" ]; then
  echo -n "Starting 192.168.0-255.x..."
  nmap 192.168.0-255.$varHosts $varNmapOpts -oG - | awk '/Up/{print $2}' | awk -F "." '{print $1 "." $2 "." $3 ".0-255"}' >> $varTempFile1
  echo " Done."
fi
varTimeDone=$(date)
echo "Done: $varTimeDone"
echo
echo "===========================[ results ]==========================="
echo
cat $varTempFile1 | sort -V | uniq | tee $varOutFile
# Remove temp file
if [ -f $varTempFile1 ]; then rm $varTempFile1; fi
echo
echo "=============================[ fin ]============================="
echo

