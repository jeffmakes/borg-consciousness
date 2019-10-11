This script alerts an administrator if a borg backup hasn't run for a while.

This script queries a remote backup repo with "borg list" to figure out the date of the most recent successful backup. If the backup was recent, a heartbeat is sent. If the backup was longer than N days ago, an alert is sent.

healthchecks.io is used for alerts so if this script or cron breaks, the heartbeats won't get to healthchecks.io and the admin will be alerted anyway.
