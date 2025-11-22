# Automating Collaborative Development Workflow Using Bash


## Overview
This project provides a simple Bash script (`monitor_and_push.sh`) that monitors a file or directory (using SHA-256 checksums), automatically stages and commits changes to Git, pushes them to a remote, and sends notification emails via the SendGrid API.


## Prerequisites
- Git installed and configured (user.name, user.email)
- A local clone of the target GitHub repository
- A SendGrid account and API key with Mail Send permissions
- `curl`, `sha256sum`, `find`, `xargs` available on your system (typical on Linux/macOS; on macOS install GNU coreutils or adapt commands)


## Files
- `monitor_and_push.sh` — the monitoring script
- `config.cfg` — configuration for the script (edit before running)
- `README.md` — this file


## Setup
1. Copy the files into a directory on your machine.
2. Edit `config.cfg` and set values:
- `REPO_PATH` — absolute path to your local git repo
- `MONITOR_PATH` — file or directory to monitor (path inside repo or absolute)
- `GIT_REMOTE`, `GIT_BRANCH`
- `SENDGRID_API_KEY`, `SENDER_EMAIL`, `RECIPIENTS`
- `POLL_INTERVAL` (seconds)


3. Make the script executable:


```bash
chmod +x monitor_and_push.sh
