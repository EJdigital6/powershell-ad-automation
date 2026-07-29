# AD Offboarding

Disables a leaver's Active Directory account from a single command — the
first and most urgent step when an employee leaves. Done manually,
offboarding is a checklist that can be missed or half-finished, leaving
security risks or unused accounts active.

Built and tested in an isolated Hyper-V lab (Windows Server 2022 domain
controller). Never tested against, or intended for, unreviewed production use.

## Features

- **Input validation** — the username parameter is mandatory, and the
  script checks the account exists before doing anything. An invalid or
  misspelled username stops the script with nothing changed.
- **Disable, not delete** — disabling preserves the user's SID,
  permissions, and data for recovery, auditing, or retention requirements.
  Deletion is a policy decision for much later, not day one.
- **Fail-safe abort** — if the disable operation fails, the script stops
  immediately rather than continuing with an incomplete offboarding. A
  half-processed leaver should never be left in an unlocked state.
- **Audit logging** — every run writes its own timestamped log file, named
  per user, recording each action and abort — so there's always an answer
  to "what was done to this account, and when?"
- **Dry-run mode** — supports PowerShell's standard `-WhatIf` switch to
  preview every action without touching AD.

## Usage

Preview first, always:

    .\Start-ADOffboarding.ps1 -SamAccountName jane.doe -WhatIf

Then the real run:

    .\Start-ADOffboarding.ps1 -SamAccountName jane.doe

## Design decisions

- **Disable comes first.** The moment offboarding starts, the security
  risk should end. If the script fails partway through any later step,
  the account is already locked — fail-safe ordering.
- **Abort on failure, don't continue.** The bulk creation script skips a
  bad row and moves on, because the next user is unrelated. Offboarding
  is the opposite: every step concerns the same leaver, so a failure
  means stop dead rather than half-complete.
- **Validate then act** — the script confirms its target exists before
  making any change, and says "nothing done" when it aborts, so the log
  is honest about inaction as well as action.

## Known limitations

- The current version disables the account only — password reset, group
  membership export and removal, and moving the account to a Leavers OU
  are planned next.
- No ticket/reason parameter yet — a future version should stamp the
  account description with the date and reference for the offboarding.
- The account is left in its original OU, so disabled leavers sit
  alongside active users until moved manually.

## Safety notes

Developed entirely in an isolated lab environment with no connection to
any production network. If adapting this for real use: review the code,
test in a non-production environment, and always run `-WhatIf` first.
