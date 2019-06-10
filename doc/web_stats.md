# Web statistics

[AWStats](https://awstats.sourceforge.io/) is a free and open source tool which analyzes web servers log files and generates usage reports. To run it for your turnkey, execute:
```
scripts/web_stats.sh 
```

Your usage report will then be available at <http://localhost:8088> (if necessary, replace "localhost" with your server URL). 

## What it looks like

![Example 1](web_stats_example_1.png)

![Example 2](web_stats_example_2.png)

## How it works

The script will:
1. dump the web server log into a local file
2. download an [AWStats Docker image](https://hub.docker.com/r/pabra/awstats) and launch it
3. generate AWStats data from the web server log
4. make available the usage report as an HTML page on port 8088