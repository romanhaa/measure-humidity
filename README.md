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
# mkvirtualenv humidity
workon humidity
python merge_tsvs.py --file_existing humidity_data.tsv --file_append humidity_new_data.tsv --file_out humidity_data.tsv
```

Optionally, create static plot of temperature and humidity measurements.

```sh
Rscript plot_humidity_temp.R
```

Launch Shiny app to interactively visualize temperature and humidity.

```sh
export PATH_DATA=/Users/roman/git/measure-humidity
Rscript run_app.R
```

## Other

```py
import pandas as pd

df = pd.read_table('humidity_data.tsv', sep='\t')
df[['day', 'time']] = df["date"].str.split(" ", 1, expand=True)
df_median = df[['day', 'temperature', 'humidity']].groupby(['day'], as_index=False).median()
```

```py
import plotly.express as px

fig = px.bar(df_median, y='humidity', x='day', text_auto='.2s')
fig.update_traces(textfont_size=12, textangle=0, textposition="outside", cliponaxis=False)
fig.show()
```

```py
from plotly.subplots import make_subplots
import plotly.graph_objects as go

fig = make_subplots(rows=2, cols=1, start_cell="top-left")
fig.add_trace(go.Bar(x=df_median["day"], y=df_median["humidity"]), row=1, col=1)
fig.add_trace(go.Bar(x=df_median["day"], y=df_median["temperature"]), row=2, col=1)
fig.show()
```
