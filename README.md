## What is it and why?
This very trivial script will log the downstream/upstream power levels as well as the SNR from your Arris SB6141 and related modem to InfluxDB or individual csv values suitable for graphing in [dygraphs](http://github.com/danvk/dygraphs).

Use it to monitor powerlevels and SNR values over time to aid in troubleshooting connectivity with your ISP. The script is easily called from a cronjob at some appropriate interval (hourly for example). It is recommended that users simply call the script via a cronjob at the disired interval. Perhaps twice per hour is enough resolution.

## Installation and Usage
* Place the script 'arris-capture.sh' in a directory of your choosing and make it executable.
* Edit the first section of the script to defining the path for storage of the log files.
* Note that this path needs to be web-exposed for dygraph to work properly.
* Place 'dygraph-combined.js' and 'index.html' into the web-exposed dir you defined above.
* Setup a cronjob to run the script at some interval.

## InfluxDB
* [InfluxDB](https://www.influxdata.com/time-series-platform/influxdb/) must be running locally (you can edit the hostname)
* The script writes to a dedicated database (arris_stats) for the modem stats.
* [Grafana](http://grafana.org/) or similar are used to pull the data out of InfluxDB and graph them.

## Notes
Note that the crude grep/awk/sed lines work fine on an Arris SB6141 running
* Firmware Name: SB_KOMODO-1.0.6.16-SCM00-NOSH
* Firmware Build Time: Feb 16 2016 11:28:04
