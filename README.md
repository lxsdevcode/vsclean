# VS Code Server Cleanup

A lightweight Bash utility to automatically remove obsolete VS Code Server installations on Linux servers and reclaim disk space.

When using VS Code Remote SSH, updates can leave older server versions in `~/.vscode-server/bin/`. Over time, these unused installations can consume hundreds of megabytes or several gigabytes of disk space.

**VS Code Server Cleanup** helps identify and remove obsolete versions while preserving installations used by running processes.

## Features

- **Dry-run mode** — preview deletions without removing any files.
- **Active version detection** — identify versions referenced by running VS Code Server processes.
- **Safe cleanup** — only target recognized version directories.
- **Automatic cleanup** — schedule periodic maintenance using cron.
- **Logging** — record cleanup activity for troubleshooting.
- **Lightweight** — requires Bash and standard Linux command-line utilities.
- **Per-user operation** — clean the VS Code Server installation belonging to the current Linux user.

## Requirements

- Linux
- Bash
- Standard utilities: `ps`, `grep`, `sort`, and `rm`
- VS Code Server installed in `~/.vscode-server/bin/`

## Installation

Clone the repository:

```bash
git clone https://github.com/lxsdevcode/vsclean.git
cd vscode-server-cleanup
```

Make the script executable:

```bash
chmod +x vsclean.sh
```

## Usage

### Preview cleanup

Run the script in dry-run mode to see which obsolete installations would be removed:

```bash
./vsclean.sh --dry-run
```

No files are deleted in this mode.

### Perform cleanup

After reviewing the dry-run output, run:

```bash
./vsclean.sh
```

The script removes recognized version directories that are not identified as active by its process checks.

### Display help

```bash
./vsclean.sh --help
```

## Automatic Cleanup with Cron

To run cleanup daily at 04:30, edit the current user's crontab:

```bash
crontab -e
```

Add:

```cron
30 4 * * * /bin/bash /path/to/vscode-server-cleanup/vsclean.sh >> "$HOME/vsclean.log" 2>&1
```

Replace `/path/to/vscode-server-cleanup/` with the actual installation path.

**Important:** Scheduled execution runs in deletion mode. Test the script with `--dry-run` first and verify that the proposed deletions are correct.

## What Gets Cleaned?

By default, the script targets version directories matching the 40-character hexadecimal commit identifier format inside:

```text
~/.vscode-server/bin/
```

For example:

```text
~/.vscode-server/bin/
├── 6d62b1d5dace93a33b3a6d3eca1317bd5e15bcb1/
└── e646868227c3e3a9e3f24277c8c7220be42c0be7/
```

If the first version is obsolete and the second is used by a running VS Code Server process, the obsolete directory can be removed to reclaim disk space.

## Safety Notes

- Always run `--dry-run` before the first cleanup.
- Process-based detection is a practical safeguard, not an absolute guarantee that a directory is unused.
- Do not run cleanup while VS Code Server is starting, updating, or changing versions.
- The script should only be run under the Linux account whose VS Code Server installation is being cleaned.
- Review the script before enabling automated deletion on production servers.
- Back up important data before performing destructive operations.

This utility does not intentionally remove user settings, extensions, workspace files, or other directories outside the targeted version directory.

## Limitations

The default target is `~/.vscode-server/bin/`. Other VS Code Server installation layouts, including installations under `~/.vscode-server/cli/servers/`, are not necessarily covered.

The script relies on process command-line inspection to identify active versions. Additional safeguards may be needed for environments with multiple concurrent sessions or unusual process isolation.

## License

This project is licensed under the MIT License.
