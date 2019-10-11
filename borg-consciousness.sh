#!/bin/bash

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=redacted
export BORG_REMOTE_PATH=redacted
# Setting this, so you won't be asked for your repository passphrase:
export BORG_PASSPHRASE='redacted'

n_days=3                  # if backup was less recent than n_days, alert administrator 
heartbeat_url="https://hc-ping.com/redacted" # using healthchecks.io for email and Telegram alerts 
fail_url="https://hc-ping.com/redacted/fail"

die()
{
    echo "Error fetching or calculating date"
    curl --retry 3 $fail_url
    exit 1
}

is_num()                        # returns (exits) 0 if passed a valid integer
{
    if (( $1 == $1 )) 2>/dev/null; then 
        return 0
    else
        return 1
    fi
}

last=`borg list --last 10 --format "{archive} {end} {NEWLINE}" | grep --invert-match checkpoint | tail -1` # get the last 10 backups from the repo, filter out checkpoints, get last one
#last="chisel-2019-10-10T03:51:01 Thu, 2019-10-4 06:59:16" # uncomment to simulate an old backup 
echo Last backup: $last

last_date=$( echo $last | cut -d " " -f 3 )
if [[ -z $last_date ]]; then
   die                          # didn't get a string
fi

last_timestamp=$( date --date=$last_date +%s 2>/dev/null ) 
now_timestamp=$( date +%s )
if ! ( ( is_num $last_timestamp ) && ( is_num $now_timestamp ) ); then
    die                         # invalid timestamp 
fi

days_ago=$( echo "($now_timestamp - $last_timestamp) / (3600 * 24)" | bc )
if ! ( ( is_num $days_ago ) && (( $days_ago >= 0 )) ); then
    die                         # invalid or negative result 
fi

# Sums successful - check backup time and send appropriate heartbeats.io request
if (( $days_ago < $n_days )); then
    echo Good - last backup was $days_ago days ago - less than the $n_days day limit 
    echo Sending heartbeat...
    curl --retry 3 $heartbeat_url
else
    echo Bad - last backup was $days_ago days ago - greater than the $n_days day limit
    echo Sending alert...
    curl --retry 3 $fail_url
fi

