#!/bin/bash
echo "Usage: ./killdoubles.sh NAMEOFPDF.pdf"
FILENAME=$1
mkdir "./.tmp"
cd "./.tmp"
gs -o doube%04d.pdf -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite "../$FILENAME"
gs -o doube%04d.bmp -sDEVICE=bmp256 "../$FILENAME"
pdfunite `sha256sum *.bmp | cut -d " " -f 1  | sort  | uniq -u  | grep -f - `sha256sum doube*.bmp`  | cut -d " " -f 3 | cut -d "." -f 1 | awk '{print $1".pdf"}'` "../$FILENAME"_optimized