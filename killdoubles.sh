#!/bin/bash

FILENAME=$1
# delete temporary directory in case it already exists - maybe add a check if the user wants to perserve his data
rm -r "./.tmp"
echo "Usage: ./killdoubles.sh NAMEOFPDF.pdf"
# create a working dir
mkdir "./.tmp"
cd "./.tmp"
echo "Converting the PDF file to single pages… (this will take a while!)"
# divide the pdf file in new pdfs, page by page
gs -o doube%04d.pdf -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite "../$FILENAME" >/dev/null &
# convert the pdf to bmp files with a resolution of 74x74 dpi
gs -o doube%04d.bmp -sDEVICE=bmp256 "../$FILENAME" >/dev/null & 
# wait for the ghostscript tasks in the background to finish
wait
echo "Conversion of files done."
echo "Looking for duplicate pages…"
# pass the current directory to the custom ruby script in order to check cryptographically which bmp files in the current folder are indeed unique
ruby ../dupehunter.rb ./ | cut -d "/" -f 2 | cut -d "." -f 1 | awk '{print $1".pdf"}' | sort > listofpdfs.txt
#                          ^ omit everything before the first '/'
#                                            ^ omit the '.bmp' file ending by ignoring everything before the first '.'
#                                                               ^ append a '.pdf' to every filename
#                                                                                       ^ sort every filename alphabetically in order to assemble the pdfs correctly
echo "Search done."
mkdir temp
FILENUMBER=1
echo "Joining unique pages… (Step 1/2)"
# loop until 'listofpdfs.txt' is empty
until [ `cat listofpdfs.txt | wc -l` -eq 0 ]
do
    # unite the first 100 PDFs in 'listofpdfs.txt' and save the result into ./temp/NUMBEROFITERATION
    # (This should be good for PDFs below of 200*100 pages because of the "too many open files"-bug)
    pdfunite $(cat listofpdfs.txt | head -n 100) ./temp/"$FILENUMBER".pdf
    # delete the first 100 files from 'listofpdfs.txt'
    cat listofpdfs.txt | tail -n +101 > listofpdfs.tmp && mv listofpdfs.tmp listofpdfs.txt
    let FILENUMBER++
done
cd temp
echo "Joining unique pages… (Step 2/2)"
pdfunite `ls *.pdf | sort -n` "$FILENAME"_unoptimized.pdf >/dev/null 
echo "Joining of PDF done."
mv "$FILENAME"_unoptimized.pdf ..
cd ..
echo "Optimizing PDF…"
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -sOutputFile=foo.pdf "$FILENAME"_unoptimized.pdf >/dev/null 
mv foo.pdf ../"$FILENAME"_withoutdupes.pdf
echo "PDF optimized. Cleaning up…"
cd ..
rm -r "./.tmp"
echo "Job done. C'ya!"