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
## Initial Creation: Mitchell Henschel 05/05/2022
##
#######################################################################

## choose the starting directory
dir_txt="$HOME/Documents/txt_files"
mkdir -p "$dir_txt"
dir_doc="$HOME/Documents/doc_files"
mkdir -p "$dir_doc"
dir_pdf="$HOME/Documents/pdf_files"
mkdir -p "$dir_pdf"

for file in ~/Downloads/*
do
	name="$(basename "$file")"
	if [ "${name##*.}" == "jpg" ] || [ "${name##*.}" == "png" ] ; then
		echo "Moving $name to $HOME/Pictures"
		mv "$file" "$HOME/Pictures/$name"
	elif [ "${name##*.}" == "doc" ] || [ "${name##*.}" == "docx" ] ; then
		echo "Moving $name to $dir_doc"
		mv "$file" "$dir_doc"
	elif [ "${name##*.}" == "txt" ] ; then
		echo "Moving $name to $dir_txt"
		mv "$file" "$dir_txt"
	elif [ "${name##*.}" == "pdf" ] ; then
		echo "Moving $name to $dir_pdf"
		mv "$file" "$dir_pdf"
	elif [ "${name##*.}" == "mp4" ]; then
		echo "Moving $name to $HOME/Videos/$name"
		mv "$file" "$HOME/Videos"
	else
		echo "No action taken on $name"
	fi
done
