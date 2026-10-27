# header.sh

## Description

A Bash utility that prepends the standard 42 header to source files in a project tree. It works for any 42 login, any project, and any directory layout — there are no personal defaults baked into the script.

The script is idempotent: if a file already starts with a 42 header, that header is stripped and replaced with a freshly generated one (new timestamp). Running it multiple times is safe.

## Usage

```bash
./header.sh -l <login> [-e <email>] [-d <dir>] [-x "<ext1> <ext2> ..."] [-n] [-h]
