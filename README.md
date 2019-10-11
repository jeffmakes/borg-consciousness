# Borg Consciousness

Assimilate yourself with your Borg backups; perceive their silent deaths.

This little bash script queries a repo to see when the last successful backup took place. It alerts you if one hasn't run for a while. It uses [healthchecks.io](https://healthchecks.io) for alerts, so you can get emails/Telgram messages/tweets/whatever. If you want, you can easily substitute a different alert service - borg-consciousness.sh just sends http requests.

borg-consciousness.sh sends a heartbeat if a recent backup is detected so, even if borg-consciousness.sh itself fails, you'll hear about it.

You can run borg-consciousness.sh from anywhere without modifying it. I run it on a cloud VM, *hostA*, which queries rsync.net server *hostB* to ensure regular backups are coming in from *laptopC* and *hostA*. To check multiple backup repos, just copy the script and point each copy at a different repo. It would be just as safe to run it on the same machine whose backups you're interested in monitoring, because of the heartbeat mechanism. 

## Usage

* Edit the `redacted` markers to point the script at your repo. 
* Edit the `heartbeat_url` and `fail_url` to point to your alert service (Register an account on [healthchecks.io](https://healthchecks.io)).
* Put the script somewhere sensible, and call it with cron. I put a symlink in /etc/cron.daily
* Test it - set the `make_it_fail` variable to simulate an old backup and receive an alert.
* Relax in the knowledge that if your backups fail, you'll hear about it.

## Dependencies

* curl
