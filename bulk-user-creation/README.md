# Bulk AD User Creation

Reads new starters from a CSV file and creates their Active Directory
accounts automatically — the job that otherwise means IT manually creating
accounts one at a time from an HR spreadsheet.

Built and tested in an isolated Hyper-V lab (Windows Server 2022 domain
controller). Never tested against, or intended for, unreviewed production use.

## Features

- **Duplicate name handling** — if `john.smith` is taken, the script
  automatically tries `john.smith2`, `john.smith3` and so on until it finds
  a free name. Based on the numbering convention used in real enterprise
  environments (I'm the third person with my name at my workplace).
- **Error handling** — each user is created inside a try/catch block. One
  bad row (e.g. a missing surname) is logged as FAILED and the run
  continues; the other users are unaffected.
- **Audit logging** — every run writes its own timestamped log file
  recording each success and failure, so there's always an answer to
  "what did the script actually do?"
- **Dry-run mode** — supports PowerShell's standard `-WhatIf` switch. A
  dry run shows exactly what would be created without touching AD, and
  the log records these entries as DRYRUN rather than SUCCESS.

## Usage

Preview first, always:

    .\New-BulkADUser.ps1 -WhatIf

Then the real run:

    .\New-BulkADUser.ps1

The CSV needs these columns (see `sample.csv`):

    FirstName,LastName,Department,JobTitle

## Design decisions

- **CN is set equal to SamAccountName.** Both must be unique (CN within
  the OU, SamAccountName domain-wide), so using one value for both means
  one uniqueness check covers everything. The user's real name is
  preserved in DisplayName, which is what appears in Outlook and the GAL.
- **Numbering starts at 2** — the existing account holder is implicitly
  number 1.
- **Screen output is clean; the log file carries timestamps.** People
  watching the run don't need timestamps; people auditing it later do.

## Known limitations

- No input pre-validation yet — a blank surname reaches AD and fails
  there (caught and logged, but a v2 improvement is validating rows
  before attempting creation).
- `-WhatIf` does not perform server-side validation — a row can pass the
  dry run and still fail the real run (discovered in testing).
- SamAccountName's 20-character limit isn't handled — very long names
  plus a numeric suffix could exceed it.
- The temporary password is set in the script — acceptable for a lab,
  would need replacing (e.g. prompting or generating per-user) before
  any real use.

## Safety notes

Developed entirely in an isolated lab environment with no connection to
any production network. If adapting this for real use: review the code,
test in a non-production environment, and always run `-WhatIf` first.
