#!/usr/bin/env sh

TIME=$(
  echo "$@" |
  sed 's#h#*60m#g'|
  sed 's#m#*60s#g'|
  sed 's#s#*1#g'|
  sed 's# #+#g' |
  bc
)

date1=$((`date +%s` + $TIME));
while [ "$date1" -ge `date +%s` ]; do
        echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)      \r";
        sleep 0.1
done
echo "Done with $@"

while :;
        do notify-send  "Done with $@";
        xset dpms force off
        xset dpms force on
        sleep 0.5
done
