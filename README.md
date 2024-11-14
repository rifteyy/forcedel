# ForceDel
## Description
This script allows users to permanently delete files in Windows, even if they're locked by other processes or require elevated permissions. After deleting, it's impossible to restore the file back.

## Usage
/q   - Runs in quiet mode without console output unless an error occurs.

/c   - Automatically confirms the irreversible action without user prompt.

/sl  - Skips checking if a process is using the file.

For example:

```forcedel.bat "C:\Windows\explorer.exe" /c /q /sl``` - Will delete end `explorer.exe` task and then delete it.

## What can it delete?
- Files locked by processes (ends the process then deletes)
- System files (Anything in %systemdrive%\Windows\*)
- Locked malware files
- Old program files

NOTE: It can not delete Windows Defender and other AV's files.
