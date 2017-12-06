#!/bin/bash
rm -r "./.tmp"
echo "Usage: ./killdoubles.sh NAMEOFPDF.pdf"
FILENAME=$1
mkdir "./.tmp"
cd "./.tmp"

gs -o doube%04d.pdf -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite "../$FILENAME"
gs -o doube%04d.bmp -sDEVICE=bmp256 "../$FILENAME"
shasum *.bmp > sha.txt
pdfunite `shasum *.bmp | cut -d " " -f 1  | sort | guniq | ggrep -f - sha.txt | guniq -w 40 | cut -d " " -f 3 | cut -d "." -f 1 | awk '{print $1".pdf"}'` "../$FILENAME"_optimized.pdf
#        ^ evaluate the command in backticks and sending it as a string to pdfunite
#          ^ generate hashes of every bmp file in the folder
#                           ^ search for every space as a delimiter; in the case of the sha1sum-command it's the sha1 hash of the file
#                                               ^ sort every sha1-hash alphabetically
#                                                       ^ only show unique hashes (so double hashes are omitted)
#                                                                         
cd ..
#rm -r "./.tmp"