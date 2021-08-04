library(tidyverse)
library(patchwork)
df <- read_tsv('humidity_data.tsv', col_names=TRUE, col_types=cols()) %>% mutate(date = as.POSIXct(strptime(date, "%Y-%m-%d %H:%M:%OS")))
p1 <- df %>% ggplot(aes(x=date)) + geom_hline(yintercept=c(40,60), color='red') + geom_line(aes(y=humidity)) + geom_smooth(aes(y=humidity), method = 'gam', formula = y ~ s(x, k = 50)) + theme_bw() + scale_x_datetime()
p2 <- df %>% ggplot(aes(x=date)) + geom_line(aes(y=temperature)) + geom_hline(yintercept=mean(df$temperature)) + geom_smooth(aes(y=temperature), method = 'gam', formula = y ~ s(x, k = 50)) + theme_bw() + scale_x_datetime()
p <- p1/p2
ggsave('humidity_temp.png', p, height=8, width=20)
