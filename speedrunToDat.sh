#!/bin/bash
DIR=data

JSON=$DIR/IL.json
DAT=$DIR/easy.dat

rm $DAT

wget "https://www.speedrun.com/api/v1/categories/82416325/records?top=1&max=50" -O $JSON

grep -oP '"realtime_t":[0-9hms]*.*?levels/[a-zA-Z0-9]*' $JSON > $DAT.temp

while read line; do
  grep -o '"realtime_t":[0-9hms]*' <<< $line | tail -1 | sed 's/[^0-9]*//g' 
done < $DAT.temp > $DAT
