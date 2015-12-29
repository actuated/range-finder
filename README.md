# range-finder
Shell script to use Nmap host discovery scans to find IANA private ranges in use.

# Usage
`range-finder.sh` requires an output file to be specified with **-o [filename]**.

`range-finder.sh` does an Nmap host discovery scan against selected hosts in IANA private IP ranges. By default, the networks 10.0-255.0-255.x, 172.16.31.x, and 192.168.0-255.x are scanned, for the hosts .1-4, .100-104, and .250-254.

**--nets [value]** allows the networks to be customized. Supported values are "10", "172", and "192". Multiple values can be separated by a comma.

**--hosts [value]** allows the hosts to be customized.

Example 1: Standard Command

`./range-finder.sh -o outputfilename.txt`

Example 2: Don't scan 192.168.x.x

`./range-finder.sh -o outputfilename.txt --nets 10,172`

Example 3: Only scan 10.0-255.0-255.1-10

`./range-finder.sh -o outputfilename.txt --nets 10 --hosts 1-10`
