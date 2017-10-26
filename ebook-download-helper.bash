#!/bin/bash

DOWNLOADLIST=$1  # take a txt file with the pdf-links as first argument
FILENAME=$2  # take the title of the book as the second argument

FILESPERPART=50  # defines how many files per part should be downlaoded. number_of_pdf_files/FILESPERPART = number_of_concurrent_downloads

echo "This tool takes a TXT file with numerically sorted PDF-links as first and the title of the book as second argument"
echo "You supplied the linklist $DOWNLOADLIST"
echo "The download of your book $FILENAME will begin shortly"

mkdir "$FILENAME" 
cp "$DOWNLOADLIST" "$FILENAME"/downloadlist.txt
cd "$FILENAME"

FOLDERNUMBER=1

until [ `cat downloadlist.txt | wc -l` -eq 0 ]
do
	mkdir "$FOLDERNUMBER"
	cat downloadlist.txt | grep -v -e "Nutzungsbedingungen" -e 'print/section' | head -n "$FILESPERPART" > "$FOLDERNUMBER"/download.txt  # take the first 100 links and put them in FOLDERNUMBER/download.txt
	cat downloadlist.txt | tail -n +"$((FILESPERPART + 1))" > downloadlist.tmp && mv downloadlist.tmp downloadlist.txt  # delete the first 100 lines of the file, since we already have them in FOLDERNUMBER/downloads.txt
	(
	cd "$FOLDERNUMBER"
	wget -U 'Mozilla/5.0 (X11; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0' -i download.txt
	pdfunite `ls *.pdf | sort -n` "$FOLDERNUMBER".pdf
	mv "$FOLDERNUMBER".pdf ../
	cd ..
	rm -r "$FOLDERNUMBER"
	) &
	let FOLDERNUMBER++
done
wait
echo "Assembling all files…"
pdfunite `ls *.pdf | sort -n` "$FILENAME"_unoptimized.pdf
echo "Done."
echo "Optimizing PDF…"
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -sOutputFile="$FILENAME".pdf "$FILENAME"_unoptimized.pdf
mv "$FILENAME".pdf ../"$FILENAME".pdf
cd ..
rm -r "$FILENAME"
echo "All done! Your book $FILENAME is ready."
