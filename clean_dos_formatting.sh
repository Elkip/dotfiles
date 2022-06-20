#! /bin/bash

#######################################################################
## Script name: fix_dos_formatting.ksh
## Purpose: Convert files into UNIX format
## and change file format to Unix
##
## Parameters:
## In (Optional): <LIST OF INPUT FILES>
## Out: 0 (SUCCESS)            1 (FAIL)      
##
## Initial Creation: Mitchell Henschel 01/05/2020
##
#######################################################################

if [ $# -gt 0 ]; then
    for FILE in "$@" ; do
        if [[ -f $FILE ]]; then
            echo 'Converting File: ' $FILE
            sed -e 's/\r$// ; 1 s/^\xef\xbb\xbf//' -i -- "$FILE" || exit 1
        elif [[ -d $FILE ]]; then
            echo "$FILE is a folder"
        else
            echo "$FILE is not valid or does not exist"
        fi

    done
else
    echo 'Usage: fix_msdos_formatting.ksh <LIST OF INPUT FILES>'
    exit 1
fi
echo 'Done'
