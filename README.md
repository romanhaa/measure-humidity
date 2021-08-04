# Collecting and visualizing temperature and humidity measurements

Connect temperature/humidity sensor to Arduino board and make it run the program in [`TimeSerial.ino`](TimeSerial.ino).

Connect Arduino board to Raspberry Pi and collect measurements.

```sh
screen -S arduino
picocom /dev/ttyACM0 >> /home/pi/humidity.tsv
# picocom /dev/ttyACM0 -b 115200 -l | tee /home/pi/humidity.tsv
# picocom -b 115200 /dev/ttyACM0 -g /home/pi/humidity.tsv
```

In a different terminal on the Raspberry Pi, send current time to Arduino board timestamp to show correct timestamp in Arduino output.

```sh
echo "T$(($(date +%s)+60*60*2))" > /dev/ttyACM0
```

On local machine, fetch data from Raspberry Pi.

```sh
rsync -arh --progress --partial pi@192.168.2.18:/home/pi/humidity.tsv ./humidity_new_data.tsv
```

Merge previously fetched data with new data.

```sh
mkvirtualenv humidity
python merge_tsvs.py --file_existing humidity_data.tsv --file_append humidity_new_data.tsv --file_out humidity_data.tsv
```

Optionally, create static plot of temperature and humidity measurements.

```sh
Rscript plot_humidity_temp.R
```

Launch Shiny app to interactively visualize temperature and humidity.

```sh
export PATH_DATA=/Users/roman/github/humidity
Rscript run_app.R
```
