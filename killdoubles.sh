#!/bin/bash

# delete temporary directory in case it already exists - maybe add a check if the user wants to perserve his data
rm -r "./.tmp"
echo "Usage: ./killdoubles.sh NAMEOFPDF.pdf"
FILENAME=$1
# create a working dir
mkdir "./.tmp"
cd "./.tmp"

echo "Converting the PDF file to single pages… (this will take a while!)"

# divide the pdf file in new pdfs, page by page
gs -o doube%04d.pdf -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite "../$FILENAME" >/dev/null &
# convert the pdf to bmp files with a resolution of 74x74 dpi
gs -o doube%04d.bmp -sDEVICE=bmp256 "../$FILENAME" >/dev/null & 
wait
echo "Conversion of files done."
echo "Looking for duplicate pages…"
ruby ../dupehunter.rb ./ | cut -d "/" -f 2 | cut -d "." -f 1 | awk '{print $1".pdf"}' | sort > listofpdfs.txt
echo "Search done."
mkdir temp
FILENUMBER=1
echo "Joining unique pages… (Step 1/2)"
until [ `cat listofpdfs.txt | wc -l` -eq 0 ]
do
    pdfunite $(cat listofpdfs.txt | head -n 100) ./temp/"$FILENUMBER".pdf
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

# run the custom dupehunter application using a custom ruby application
# pdfunite $(ruby ../dupehunter.rb ./ | cut -d "/" -f 2 | cut -d "." -f 1 | awk '{print $1".pdf"}' | sort) "../$FILENAME"_withoutdupes.pdf
#        ^ evaluate the command insite the $() before running pdfunite and passing the result to pdfunite as an argument
#                                     ^ only use the content of the output *after* the first '/'
#                                                     ^ only pass on the output of the command before the first dot (to omit the file extension .bmp) 
#                                                                        ^ append a '.pdf' to the result in order to have a list of filenames we can pass to pdfunite      
                                                 
cd ..
rm -r "./.tmp"

echo "Job done. C'ya!"