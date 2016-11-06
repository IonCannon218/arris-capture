#!/bin/bash
# Original script by graysky https://github.com/graysky2/bin/blob/master/arris_signals
# Modified for Arris SB6141 in 2016 by IonCannon218 https://github.com/IonCannon218/arris-capture
#

# PREFACE
# This very trivial script will log the downstream/upstream power levels
# as well as the respective SNR from your Arris TM822 and related modem
# to individual csv values suitable for graphing in dygraphs[1].
#
# Use it to monitor power levels, frequencies, and SNR values over time to aid
# in troubleshooting connectivity with your ISP. The script is easily called
# from a cronjob at some appropriate interval (hourly for example).
#
# It is recommended that users simply call the script via a cronjob at the
# desired interval. Perhaps twice per hour is enough resolution.
#
# Note that the crude grep/awk/sed lines work fine on an Arris TM822G running
# Firmware            : TS070659C_050313_MODEL_7_8_SIP_PC20
# Firmware build time : Fri May 3 11:18:59 EDT 2013

# INSTALLATION
# 1. Place the script 'capture_arris_for_dygraphs.sh' in a directory of your
#    choosing and make it executable. Edit it to defining the correct path
#    for storage of the log files which need to be web-exposed for dygraph
#    to work properly.
#
# 2. Place 'dygraph-combined.js' and 'index.html' into the web-exposed dir you
#    defined in step #1.

# REFERENCES
# 1. https://github.com/danvk/dygraphs

###############               Configuration            #####################
# TEMP is the full path to the temp file wget will grab from your modem.
#      it is recommended to use something in tmpfs like /tmp for example.
TEMP=/tmp/snapshot.html

# LOGPATH is the full path to the log file you will keep.
LOGPATH=/tmp/arris-stats/

# If you want to log all html snapshots set KEEPTHEM to any value
# Be sure that you have sufficient storage for this as files are around 5 Kb
# and can add up over time!
KEEPTHEM=yes

###############       Do not edit below this line         ##################
###############    Unless you know what you're doing      ##################

fail() {
	echo "$RUNDATE Modem is unreachable" >> "$LOGPATH/arris_errors.txt"
	exit 1
}

RUNDATE=$(date "+%F %T")
[[ ! -d "$LOGPATH" ]] && echo "You defined an invalid LOGPATH!" && exit 1

# remove old dump file to avoid duplicate entries
[[ -f "$TEMP" ]] && rm -f "$TEMP"

# try to get stats 6 times waiting 10 sec per time
wget -q -T 10 -t 6 http://192.168.100.1/cmSignalData.htm -O $TEMP || fail

if [[ -n "$KEEPTHEM" ]]; then
	SAVE="$LOGPATH/snapshots"
	CAPDATE=$(date -d "$RUNDATE" "+%Y%m%d_%H%M%S")
	[[ ! -d "$SAVE" ]] && mkdir "$SAVE"
	[[ -f "$TEMP" ]] && cp "$TEMP" "$SAVE/$CAPDATE.html"
fi

# find downstream frequencies
DF1=$(head -33 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $2 }' | sed 's/ Hz.*//')
DF2=$(head -33 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $3 }' | sed 's/ Hz.*//')
DF3=$(head -33 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $4 }' | sed 's/ Hz.*//')
DF4=$(head -33 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $5 }' | sed 's/ Hz.*//')
DF5=$(head -33 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $6 }' | sed 's/ Hz.*//')
DF6=$(head -33 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $7 }' | sed 's/ Hz.*//')
DF7=$(head -33 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $8 }' | sed 's/ Hz.*//')
DF8=$(head -33 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $9 }' | sed 's/ Hz.*//')

# downstream power
DP1=$(head -36 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')
DP2=$(head -37 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')
DP3=$(head -38 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')
DP4=$(head -39 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')
DP5=$(head -40 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')
DP6=$(head -41 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')
DP7=$(head -42 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')
DP8=$(head -43 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')

# downstream snr
DS1=$(head -34 $TEMP | tail -1 | grep 'dB' | awk -F'<TD>' '{ print $2 }' | sed 's| dB.*||')
DS2=$(head -34 $TEMP | tail -1 | grep 'dB' | awk -F'<TD>' '{ print $3 }' | sed 's| dB.*||')
DS3=$(head -34 $TEMP | tail -1 | grep 'dB' | awk -F'<TD>' '{ print $4 }' | sed 's| dB.*||')
DS4=$(head -34 $TEMP | tail -1 | grep 'dB' | awk -F'<TD>' '{ print $5 }' | sed 's| dB.*||')
DS5=$(head -34 $TEMP | tail -1 | grep 'dB' | awk -F'<TD>' '{ print $6 }' | sed 's| dB.*||')
DS6=$(head -34 $TEMP | tail -1 | grep 'dB' | awk -F'<TD>' '{ print $7 }' | sed 's| dB.*||')
DS7=$(head -34 $TEMP | tail -1 | grep 'dB' | awk -F'<TD>' '{ print $8 }' | sed 's| dB.*||')
DS8=$(head -34 $TEMP | tail -1 | grep 'dB' | awk -F'<TD>' '{ print $9 }' | sed 's| dB.*||')

# downstream unerrored codewords
DUC1=$(head -83 $TEMP | tail -1 | awk -F'<TD>' '{ print $2 }' | sed 's|&nbsp.*||')
DUC2=$(head -83 $TEMP | tail -1 | awk -F'<TD>' '{ print $3 }' | sed 's|&nbsp.*||')
DUC3=$(head -83 $TEMP | tail -1 | awk -F'<TD>' '{ print $4 }' | sed 's|&nbsp.*||')
DUC4=$(head -83 $TEMP | tail -1 | awk -F'<TD>' '{ print $5 }' | sed 's|&nbsp.*||')
DUC5=$(head -83 $TEMP | tail -1 | awk -F'<TD>' '{ print $6 }' | sed 's|&nbsp.*||')
DUC6=$(head -83 $TEMP | tail -1 | awk -F'<TD>' '{ print $7 }' | sed 's|&nbsp.*||')
DUC7=$(head -83 $TEMP | tail -1 | awk -F'<TD>' '{ print $8 }' | sed 's|&nbsp.*||')
DUC8=$(head -83 $TEMP | tail -1 | awk -F'<TD>' '{ print $9 }' | sed 's|&nbsp.*||')

# downstream correctable codewords
DCC1=$(head -84 $TEMP | tail -1 | awk -F'<TD>' '{ print $2 }' | sed 's|&nbsp.*||')
DCC2=$(head -84 $TEMP | tail -1 | awk -F'<TD>' '{ print $3 }' | sed 's|&nbsp.*||')
DCC3=$(head -84 $TEMP | tail -1 | awk -F'<TD>' '{ print $4 }' | sed 's|&nbsp.*||')
DCC4=$(head -84 $TEMP | tail -1 | awk -F'<TD>' '{ print $5 }' | sed 's|&nbsp.*||')
DCC5=$(head -84 $TEMP | tail -1 | awk -F'<TD>' '{ print $6 }' | sed 's|&nbsp.*||')
DCC6=$(head -84 $TEMP | tail -1 | awk -F'<TD>' '{ print $7 }' | sed 's|&nbsp.*||')
DCC7=$(head -84 $TEMP | tail -1 | awk -F'<TD>' '{ print $8 }' | sed 's|&nbsp.*||')
DCC8=$(head -84 $TEMP | tail -1 | awk -F'<TD>' '{ print $9 }' | sed 's|&nbsp.*||')

# downstream uncorrectable codewords
DEC1=$(head -85 $TEMP | tail -1 | awk -F'<TD>' '{ print $2 }' | sed 's|&nbsp.*||')
DEC2=$(head -85 $TEMP | tail -1 | awk -F'<TD>' '{ print $3 }' | sed 's|&nbsp.*||')
DEC3=$(head -85 $TEMP | tail -1 | awk -F'<TD>' '{ print $4 }' | sed 's|&nbsp.*||')
DEC4=$(head -85 $TEMP | tail -1 | awk -F'<TD>' '{ print $5 }' | sed 's|&nbsp.*||')
DEC5=$(head -85 $TEMP | tail -1 | awk -F'<TD>' '{ print $6 }' | sed 's|&nbsp.*||')
DEC6=$(head -85 $TEMP | tail -1 | awk -F'<TD>' '{ print $7 }' | sed 's|&nbsp.*||')
DEC7=$(head -85 $TEMP | tail -1 | awk -F'<TD>' '{ print $8 }' | sed 's|&nbsp.*||')
DEC8=$(head -85 $TEMP | tail -1 | awk -F'<TD>' '{ print $9 }' | sed 's|&nbsp.*||')

# find upstream frequencies
UF1=$(head -57 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $2 }' | sed 's/ Hz.*//')
UF2=$(head -57 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $3 }' | sed 's/ Hz.*//')
UF3=$(head -57 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $4 }' | sed 's/ Hz.*//')
UF4=$(head -57 $TEMP | tail -1 | grep 'Hz' | awk -F'<TD>' '{ print $5 }' | sed 's/ Hz.*//')

# upstream power
UP1=$(head -60 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $2 }' | sed 's| dBmV.*||')
UP2=$(head -60 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $3 }' | sed 's| dBmV.*||')
UP3=$(head -60 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $4 }' | sed 's| dBmV.*||')
UP4=$(head -60 $TEMP | tail -1 | grep 'dBmV' | awk -F'<TD>' '{ print $5 }' | sed 's| dBmV.*||')


# force a 0 value when undefined due to poor connectivity
[[ "$DF1" = "----</TD>" ]] && DF1=0
[[ "$DF2" = "----</TD>" ]] && DF2=0
[[ "$DF3" = "----</TD>" ]] && DF3=0
[[ "$DF4" = "----</TD>" ]] && DF4=0
[[ "$DF5" = "----</TD>" ]] && DF5=0
[[ "$DF6" = "----</TD>" ]] && DF6=0
[[ "$DF7" = "----</TD>" ]] && DF7=0
[[ "$DF8" = "----</TD>" ]] && DF8=0

[[ "$DP1" = "----</TD>" ]] && DP1=0
[[ "$DP2" = "----</TD>" ]] && DP2=0
[[ "$DP3" = "----</TD>" ]] && DP3=0
[[ "$DP4" = "----</TD>" ]] && DP4=0
[[ "$DP5" = "----</TD>" ]] && DP5=0
[[ "$DP6" = "----</TD>" ]] && DP6=0
[[ "$DP7" = "----</TD>" ]] && DP7=0
[[ "$DP8" = "----</TD>" ]] && DP8=0

[[ "$DS1" = "----</TD>" ]] && DS1=0
[[ "$DS2" = "----</TD>" ]] && DS2=0
[[ "$DS3" = "----</TD>" ]] && DS3=0
[[ "$DS4" = "----</TD>" ]] && DS4=0
[[ "$DS5" = "----</TD>" ]] && DS5=0
[[ "$DS6" = "----</TD>" ]] && DS6=0
[[ "$DS7" = "----</TD>" ]] && DS7=0
[[ "$DS8" = "----</TD>" ]] && DS8=0

[[ "$UF1" = "----</TD>" ]] && UF1=0
[[ "$UF2" = "----</TD>" ]] && UF2=0
[[ "$UF3" = "----</TD>" ]] && UF3=0
[[ "$UF4" = "----</TD>" ]] && UF4=0
[[ -z "$UF1" ]] && UF1=0
[[ -z "$UF2" ]] && UF2=0
[[ -z "$UF3" ]] && UF3=0
[[ -z "$UF4" ]] && UF4=0

[[ "$UP1" = "----</TD>" ]] && UP1=0
[[ "$UP2" = "----</TD>" ]] && UP2=0
[[ "$UP3" = "----</TD>" ]] && UP3=0
[[ "$UP4" = "----</TD>" ]] && UP4=0
[[ -z "$UP1" ]] && UP1=0
[[ -z "$UP2" ]] && UP2=0
[[ -z "$UP3" ]] && UP3=0
[[ -z "$UP4" ]] && UP4=0


# Test output
echo "Downstream freq: $DF1, $DF2, $DF3, $DF4, $DF5, $DF6, $DF7, $DF8"
echo "Downstream power: $DP1, $DP2, $DP3, $DP4, $DP5, $DP6, $DP7, $DP8"
echo "Downstream SNR: $DS1, $DS2, $DS3, $DS4, $DS5, $DS6, $DS7, $DS8"
echo ""
echo "Upstream freq: $UF1, $UF2, $UF3, $UF4"
echo "Upstream power: $UP1, $UP2, $UP3, $UP4"
echo ""
echo "Downstream Unerrored Codewords: $DUC1, $DUC2, $DUC3, $DUC4, $DUC5, $DUC6, $DUC7, $DUC8"
echo "Downstream Correctable Codewords: $DCC1, $DCC2, $DCC3, $DCC4, $DCC5, $DCC6, $DCC7, $DCC8"
echo "Downstream Uncorrectable Codewords: $DEC1, $DEC2, $DEC3, $DEC4, $DEC5, $DEC6, $DEC7, $DEC8"


# Write to InfluxDB TSDB
curl -s -i -XPOST 'http://localhost:8086/write?db=arris_stats' --data-binary "downstream_freq,channel=1 value=$DF1
downstream_freq,channel=2 value=$DF2
downstream_freq,channel=3 value=$DF3
downstream_freq,channel=4 value=$DF4
downstream_freq,channel=5 value=$DF5
downstream_freq,channel=6 value=$DF6
downstream_freq,channel=7 value=$DF7
downstream_freq,channel=8 value=$DF8
downstream_power,channel=1 value=$DP1
downstream_power,channel=2 value=$DP2
downstream_power,channel=3 value=$DP3
downstream_power,channel=4 value=$DP4
downstream_power,channel=5 value=$DP5
downstream_power,channel=6 value=$DP6
downstream_power,channel=7 value=$DP7
downstream_power,channel=8 value=$DP8
downstream_snr,channel=1 value=$DS1
downstream_snr,channel=2 value=$DS2
downstream_snr,channel=3 value=$DS3
downstream_snr,channel=4 value=$DS4
downstream_snr,channel=5 value=$DS5
downstream_snr,channel=6 value=$DS6
downstream_snr,channel=7 value=$DS7
downstream_snr,channel=8 value=$DS8
downstream_unerrored_codewords,channel=1 value=$DUC1
downstream_unerrored_codewords,channel=2 value=$DUC2
downstream_unerrored_codewords,channel=3 value=$DUC3
downstream_unerrored_codewords,channel=4 value=$DUC4
downstream_unerrored_codewords,channel=5 value=$DUC5
downstream_unerrored_codewords,channel=6 value=$DUC6
downstream_unerrored_codewords,channel=7 value=$DUC7
downstream_unerrored_codewords,channel=8 value=$DUC8
downstream_correctable_codewords,channel=1 value=$DCC1
downstream_correctable_codewords,channel=2 value=$DCC2
downstream_correctable_codewords,channel=3 value=$DCC3
downstream_correctable_codewords,channel=4 value=$DCC4
downstream_correctable_codewords,channel=5 value=$DCC5
downstream_correctable_codewords,channel=6 value=$DCC6
downstream_correctable_codewords,channel=7 value=$DCC7
downstream_correctable_codewords,channel=8 value=$DCC8
downstream_uncorrectable_codewords,channel=1 value=$DEC1
downstream_uncorrectable_codewords,channel=2 value=$DEC2
downstream_uncorrectable_codewords,channel=3 value=$DEC3
downstream_uncorrectable_codewords,channel=4 value=$DEC4
downstream_uncorrectable_codewords,channel=5 value=$DEC5
downstream_uncorrectable_codewords,channel=6 value=$DEC6
downstream_uncorrectable_codewords,channel=7 value=$DEC7
downstream_uncorrectable_codewords,channel=8 value=$DEC8
upstream_freq,channel=1 value=$UF1
upstream_freq,channel=2 value=$UF2
upstream_freq,channel=3 value=$UF3
upstream_freq,channel=4 value=$UF4
upstream_power,channel=1 value=$UP1
upstream_power,channel=2 value=$UP2
upstream_power,channel=3 value=$UP3
upstream_power,channel=4 value=$UP4" >/dev/null


# The old CSV format logs from the original script
#
# The individual log files
# DLOGFREQ="$LOGPATH/downstream-freq.csv"
# DLOGPOWER="$LOGPATH/downstream-power.csv"
# DLOGSNR="$LOGPATH/downstream-SNR.csv"
# ULOGFREQ="$LOGPATH/upstream-freq.csv"
# ULOGPOWER="$LOGPATH/upstream-power.csv"

# # # downstream frequency log
# [[ ! -f $DLOGFREQ ]] && echo "DTS,Downstream 1,Downstream 2,Downstream 3,Downstream 4,Downstream 5,Downstream 6,Downstream 7,Downstream 8" > $DLOGFREQ
# echo "$RUNDATE,${DF1/ *},${DF2/ *},${DF3/ *},${DF4/ *},${DF5/ *},${DF6/ *},${DF7/ *},${DF8/ *}" >> $DLOGFREQ

# # # downstream power log
# [[ ! -f $DLOGPOWER ]] && echo "DTS,Downstream 1,Downstream 2,Downstream 3,Downstream 4,Downstream 5,Downstream 6,Downstream 7,Downstream 8" > $DLOGPOWER
# echo "$RUNDATE,$DP1,$DP2,$DP3,$DP4,$DP5,$DP6,$DP7,$DP8" >> $DLOGPOWER

# # # downstream SNR log
# [[ ! -f $DLOGSNR ]] && echo "DTS,Downstream 1,Downstream 2,Downstream 3,Downstream 4,Downstream 5,Downstream 6,Downstream 7,Downstream 8" > $DLOGSNR
# echo "$RUNDATE,$DS1,$DS2,$DS3,$DS4,$DS5,$DS6,$DS7,$DS8" >> $DLOGSNR

# # # upstream freq log
# [[ ! -f $ULOGFREQ ]] && echo "DTS,Upstream 1,Upstream 2,Upstream 3,Upstream 4" > $ULOGFREQ
# echo "$RUNDATE,${UF1/ *},${UF2/ *},${UF3/ *},${UF4/ *}" >> $ULOGFREQ

# # # upstream power log
# [[ ! -f $ULOGPOWER ]] && echo "DTS,Upstream 1,Upstream 2,Upstream 3,Upstream 4" > $ULOGPOWER
# echo "$RUNDATE,$UP1,$UP2,$UP3,$UP4" >> $ULOGPOWER