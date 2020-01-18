#! /bin/bash

## create the directory, -p means it will create parent dirs
## and not complain if the file already exists
dir_txt="$HOME/Documents/txt_files"
mkdir -p "$dir_txt"
dir_doc="$HOME/Documents/doc_files"
mkdir -p "$dir_doc"
dir_pdf="$HOME/Documents/pdf_files"
mkdir -p "$dir_pdf"

for file in ~/Downloads/*
do
	## basename removes file path and remove the extension if
	## a second arg is provided
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
