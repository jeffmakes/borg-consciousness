#!/bin/bash

export BORG_REPO='user@server.domain:my-repo-name' # point to your borg repo; 
#if you use SSH, you can also use the following format:
#export BORG_REPO='ssh://user@server.domain/./repo' 

export BORG_RSH='ssh -i /root/.ssh/privateKey' #point to your SSH private key
export BORG_REMOTE_PATH=/usr/local/bin/borg1/borg1 # point to your borg executable 
export BORG_PASSPHRASE='redacted'

n_days=3                  # if backup was less recent than n_days, alert administrator 
heartbeat_url="https://hc-ping.com/redacted" # using healthchecks.io for email/Telegram/whatever alerts 
fail_url="https://hc-ping.com/redacted/fail"
make_it_fail=0                  # set to 1 to test your alerts by simulating an old backup 

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

#If you are using BusyBox (e.g. inside borgmatic docker), you can comment the above command and use the following instead:
#last=`borg list --last 10 --format "{archive} {end} {NEWLINE}" | grep -v checkpoint | tail -1` # get the last 10 backups from the repo, filter out checkpoints, get last one


if (( $make_it_fail )); then
    last="qwho-1989-05-08T11:11:11 Thu, 1989-05-08 11:11:11" # simulate an old backup
fi

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

