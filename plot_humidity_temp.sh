#!/bin/bash

rsync -arh --progress --partial pi@192.168.2.18:/home/pi/humidity.tsv ./humidity_2.tsv
# Rscript plot_humidity_temp.R
# open humidity_temp.png
