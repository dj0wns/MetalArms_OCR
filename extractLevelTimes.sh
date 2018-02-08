#!/bin/bash

rm times.dat

convert temp/*.png output.pdf

for file in temp/temp_level* ; do
  agrep -1 "00:0[0-9]:[0-9][0-9]" $file >> times.dat
  echo "---------" >> times.dat
done
