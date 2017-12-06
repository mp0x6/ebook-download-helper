#!/bin/bash
rm -r "./.tmp"
echo "Usage: ./killdoubles.sh NAMEOFPDF.pdf"
FILENAME=$1
mkdir "./.tmp"
cd "./.tmp"

gs -o doube%04d.pdf -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite "../$FILENAME"
gs -o doube%04d.bmp -sDEVICE=bmp256 "../$FILENAME"
shasum *.bmp > sha.txt

pdfunite $(ruby ../dupehunter.rb ./ | cut -d "/" -f 2 | cut -d "." -f 1 | awk '{print $1".pdf"}' | sort) "../$FILENAME"_withoutdupes.pdf
                                                 
cd ..
rm -r "./.tmp"