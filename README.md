# header.sh

## Description

A small Bash utility that prepends the standard 42 header to every `.c` and `.h` file in the current directory. The script is idempotent: if a file already starts with a 42 header, that header is stripped and replaced with a freshly generated one (new timestamp), so running it multiple times is safe.

The login and email can be overridden from the command line; sensible defaults are provided.

## Usage

```bash
./header.sh [login] [email]
