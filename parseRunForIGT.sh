#!/bin/bash

DAT=data/easy.dat
TEMP=temp/temp
NUM_THREADS=4
PIDS=""
SEEKTIME=5
SKIPTIME=12
ARBITRARYOFFSET=1
CONTRAST=25000

i=0
j=1

fuzzyMatch () {
  FUZZYRESULT=$(agrep -i -7 "Completion Time:"  $1)
}

timeMatch () {
  TIMERESULT=$(agrep -1  "00:0[0-9]:[0-9][0-9]" $1)
}

#while read -r line; do
for (( h = 1 ; h < 43 ; h++ )) ; do
  line=$(sed "${h}q;d" $DAT)
  line=$((line + SKIPTIME))
  inc=$((line / 3))
  i=$((i + inc))
  while :; do
    echo $i
    
    PIDS=""
    
    for (( k=0 ; k<$NUM_THREADS ; k++ )); do
      convert stills/out$((i + k)).png -set colorspace Gray -separate -average -level 0,$CONTRAST,0.02 stills/out$((i + k))_grey.png &
      pids="$pids $!"
    done
    
    wait $pids
    
    PIDS=""
    
    for (( k=0 ; k<$NUM_THREADS ; k++ )); do
      tesseract stills/out$((i + k))_grey.png ${TEMP}${k} &
      pids="$pids $!"
    done
    
    wait $pids
    
    for (( k=0 ; k<$NUM_THREADS ; k++ )); do
      fuzzyMatch ${TEMP}${k}.txt ;
      if [[ $FUZZYRESULT != "" ]] ; then
        timeMatch ${TEMP}${k}.txt ;
        if [[ $TIMERESULT != "" ]] ; then
          echo "$TIMERESULT"
          JTEMP=$(printf "%02d" $j)
          cat  ${TEMP}${k}.txt > ${TEMP}_level_${JTEMP}_frame_$((i + k)).txt
          cp stills/out$((i + k)).png ${TEMP}_level_${JTEMP}_frame_$((i+k)).png
          break 2;
        else
          echo "Checking close frames:"
          SEEK=$((i + k))
          SEEK=$((SEEK * 3))
          echo "ffmpeg -i input.mp4 -ss $((SEEK + 1)) -vframes 1 stills/out$((i + k))_1.png"
          ffmpeg -y -ss $((SEEK + 0 - SEEKTIME - ARBITRARYOFFSET)).5 -i input.mp4 -ss ${SEEKTIME} -vframes 1 stills/out$((i + k))_1.png 
          ffmpeg -y -ss $((SEEK + 1 - SEEKTIME - ARBITRARYOFFSET)) -i input.mp4 -ss ${SEEKTIME} -vframes 1 stills/out$((i + k))_2.png 
          ffmpeg -y -ss $((SEEK - 1 - SEEKTIME - ARBITRARYOFFSET)).5 -i input.mp4 -ss ${SEEKTIME} -vframes 1 stills/out$((i + k))_3.png 
          ffmpeg -y -ss $((SEEK - 1 - SEEKTIME - ARBITRARYOFFSET)) -i input.mp4 -ss ${SEEKTIME} -vframes 1 stills/out$((i + k))_4.png 

          PIDS=""
          
          for (( l=1 ; l<5 ; l++ )); do
            convert stills/out$((i + k))_${l}.png -set colorspace Gray -separate -average -level 0,$CONTRAST,0.02 stills/out$((i + k))_${l}_grey.png &
            pids="$pids $!"
          done
          
          wait $pids
          
          PIDS=""
          
          for (( l=1 ; l<5 ; l++ )); do
            tesseract stills/out$((i + k))_${l}_grey.png ${TEMP}${k}_${l} &
            pids="$pids $!"
          done
          
          wait $pids
          
          for (( l=1 ; l<5 ; l++ )); do
            timeMatch ${TEMP}${k}_${l}.txt ;
            if [[ $TIMERESULT != "" ]] ; then
              echo "$TIMERESULT"
              JTEMP=$(printf "%02d" $j)
              cat  ${TEMP}${k}_${l}.txt > ${TEMP}_level_${JTEMP}_frame_$((i + k)).txt
              cp stills/out$((i + k))_${l}.png ${TEMP}_level_${JTEMP}_frame_$((i+k)).png
              #cat  ${TEMP}${k}_${l}.txt > ${TEMP}_level_${JTEMP}_frame_$((i + k))_frame_alter.txt
              break 3;
            fi
          done
          
          echo "UNABLE TO FIND RESULT"
          JTEMP=$(printf "%02d" $j)
          cat  ${TEMP}${k}.txt > ${TEMP}_level_${JTEMP}_frame_$((i + k)).txt
          cat  ${TEMP}${k}.txt > ${TEMP}_level_${JTEMP}_frame_$((i + k))_unable.txt
          cp stills/out$((i + k)).png ${TEMP}_level_${JTEMP}_frame_$((i+k)).png
          break 2;

        fi
      fi
    done

    i=$((i + 4))

  done

  ((j++))
done
#done < $DAT
