# Borg Consciousness

Assimilate yourself with your Borg backups - perceive their silent deaths.

This little bash script queries a repo to see when the last successful backup took place. It alerts you if one hasn't run for a while. It uses [https://healthchecks.io](healthchecks.io) for alers, so you can get emails/Telgram messages/tweets/whatever. If you want, you can easily substitute a different alert service - borg-consciousness.sh just sends http requests.

borg-consciousness.sh sends heartbeats if a recent backup is detected, so even if borg-consciousness.sh itself fails you'll hear about it.

## Usage

* Edit the `redacted` markers to point the script at your repo. 
* Edit the `heartbeat_url` and `fail_url` to point to your alert service (Register an account on [https://healthchecks.io](healthchecks.io)). 
* Put the script somewhere sensible, and call it with cron. I put a symlink in /etc/cron.daily
* Test it - set the `make_it_fail` variable to simulate an old backup and receive an alert.
* Relax in the knowledge that if your backups fail, you'll hear about it.

## Dependencies

* curl
