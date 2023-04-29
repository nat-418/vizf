# vizf
A script to fuzzy-find file(s) using [fd](https://github.com/sharkdp/fd) with
[fzf](https://github.com/junegunn/fzf) and open them for editing.

## Dependencies
- fdf
- fzf
- Tcl

## Rationale
I tend to work in the terminal and pop in and out of my text editor frequently.
Although I have fzf integrated in my editor, I don't like the workflow of opening
my editor first and then searching for files. I want to quickly select the file(s)
first and then get to work.

## Usage
`$ vizf [options...] path pattern`

This script calls Fzf with multi-selection enabled, so you can hit `<Tab>` to
select multiple files. If given a path like `~/Code`, fzf will match only on
files and beneath that path, e.g., the `/foo` in `~/Code/foo`.

I tend to bind shell abbreviations like `vin` to `vizf ~/.config/nvim/`.

## Install

Download the script, mark it executable, and put in on your `$PATH`.
