#/bin/bash

ffmpeg -i $1 -vf fps=1/3 stills/out%d.png -hide_banner
