#!/usr/bin/env tclsh
#//#
# This file provides a script to fuzzy-find file(s)
# using bat(1), fd(1), and fzf(1)—then open them for editing.
#
# @author nat-418
# @version 0.1.0 
#//#

package require Tcl 8.6

set version 0.1.0

set help [string trim [subst -nocommands {
vizf v$version -- Fuzzy-find and open files with vi/\$VISUAL

Usage:
  vizf [options...] path pattern

Options:
  -h, --help       Show this help message
  -v, --version    Show version number

Note:
  vizf depends on fd(1) and fzf(1). Both path and pattern are passed to fd,
  and the pattern syntax is described in detail here:
  https://docs.rs/regex/1.0.0/regex/#syntax
}]]

# Prepare environment variables and command-line arguments.
#
# @param env      array of environment variables
# @param argv     list of command-line arguments
# @param help     string describing how to use this program
# @param version  string representing the current program version
# @return         list of relevant user inputs
proc parseCLI {env argv help version} {
    proc checkDependency {name} {
        try {
            exec which $name
        } on error {error_message} {
            puts stderr "Error: missing required dependency $name"
            exit 1
        }
    }

    try {
        set editor $env(VISUAL)
    } on error {error_message} {
        set editor vi
    }

    checkDependency bat
    checkDependency $editor
    checkDependency fd
    checkDependency fzf

    switch -regexp $argv {
        -h|--help {
            puts $help
            exit 0
        }
        -v|--version {
            puts $version
            exit 0
        }
    }

    lassign $argv path pattern

    if {$path eq ""} {
        set path .
    }

    if {![file exists $path]} {
        puts stderr "Error: path does not exist"
        exit 1
    }

    if {$pattern eq ""} {set pattern .}

    return [list $editor $path $pattern]
}

# Find and open file(s) for editing
#
# @param editor   program to use for editing file(s)
# @param path     path to select file(s) from
# @param pattern  regular expression to match files in path
# @return         nothing, hands interaction over to editor
proc fuzzyFind {editor path pattern} {
    set first [expr {[llength [file split $path]] + 1}]
    set files [exec fd $pattern $path --type file]

    lappend fzf_options --delimiter=/
    lappend fzf_options --multi
    lappend fzf_options --nth=$first..-1
    lappend fzf_options --scheme=path
    lappend fzf_options [subst [string trim {
        --preview=bat\ --color=always\ --theme=gruvbox-dark\ --style=snip\ {}
    }]]
    lappend fzf_options --preview-window=top

    try {
        set selection [
            exec fzf {*}$fzf_options << $files 2>@ stderr
        ]
    } on error {error_message} {
        if {$error_message eq "child process exited abnormally"} {
            # Don't alert the user that they Escape'd out of FZF
            exit 0
        } else {
            puts stderr "Error: FZF selection failed"
            puts stderr $error_message
            exit 1
        }
    }

    try {
        exec $editor {*}$selection <@ stdin >@ stdout 2>@ stderr
    } on error {error_message} {
        puts "Error: failed to open selected file with $editor"
        puts $error_message
        exit 1
    }
}

fuzzyFind {*}[parseCLI env $argv $help $version]
