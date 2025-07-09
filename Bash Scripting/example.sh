#!/bin/bash

greeting="Hello"
user=$(whoami)
day=$(date +%A)

echo "$greeting $user! Today is $day,which is the best day of the entire week"
echo "Your bash shell version is: $BASH_VERSION.Enjoy!"
echo "Here is your current disk space"

df -h /

echo "Well we do see that you are intrested in stocks"
echo "Here is a price for few of them"

curl -X GET "https://api.polygon.io/v3/reference/dividends?apiKey=$polgon_api_key"