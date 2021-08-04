
```sh
screen -S arduino
picocom /dev/ttyACM0 >> /home/pi/humidity.tsv
# picocom /dev/ttyACM0 -b 115200 -l | tee /home/pi/humidity.tsv
# picocom -b 115200 /dev/ttyACM0 -g /home/pi/humidity.tsv
```

```sh
echo "T$(($(date +%s)+60*60*2))" > /dev/ttyACM0
```

```sh
rsync -arh --progress --partial pi@192.168.2.18:/home/pi/humidity.tsv ./humidity_new_data.tsv
```

```sh
mkvirtualenv humidity
python merge_tsvs.py --file_existing humidity_data.tsv --file_append humidity_new_data.tsv --file_out humidity_data.tsv
```

```sh
Rscript plot_humidity_temp.R
```

```r
library(tidyverse)
library(patchwork)
df <- read_tsv('humidity_data.tsv', col_names=TRUE, col_types=cols()) %>% mutate(date = as.POSIXct(strptime(date, "%Y-%m-%dT%H:%M:%OS")))
p1 <- df %>% ggplot(aes(x=date)) + geom_hline(yintercept=c(40,60), color='red') + geom_line(aes(y=humidity)) + geom_smooth(aes(y=humidity), method = 'gam', formula = y ~ s(x, k = 50)) + theme_bw() + scale_x_datetime()
p2 <- df %>% ggplot(aes(x=date)) + geom_line(aes(y=temperature)) + geom_hline(yintercept=mean(df$temperature)) + geom_smooth(aes(y=temperature), method = 'gam', formula = y ~ s(x, k = 50)) + theme_bw() + scale_x_datetime()
p <- p1/p2
ggsave('humidity_temp.png', p, height=8, width=20)
```

```sh
export PATH_DATA=/Users/roman/github/humidity
Rscript run_app.R
```
