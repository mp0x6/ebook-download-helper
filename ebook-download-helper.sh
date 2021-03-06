#!/bin/bash

DOWNLOADLIST=$1  # take a txt file with the pdf-links as first argument
FILENAME=$2  # take the title of the book as the second argument
COOKIES=$3

FILESPERPART=100  # defines how many files per part should be downlaoded. number_of_pdf_files/FILESPERPART = number_of_concurrent_downloads

echo "This tool takes a TXT file with numerically sorted PDF-links as first and the title of the book as second argument"
echo "You supplied the linklist $DOWNLOADLIST"
echo "The download of your book $FILENAME will begin shortly"

if [ -d "$FILENAME" ]; then
	echo "Warning! There already is a folder named $FILENAME. The execution of this script would delete it."
	exit 1
fi

mkdir "$FILENAME" 
cp "$DOWNLOADLIST" "$FILENAME"/downloadlist.txt
cd "$FILENAME"

FOLDERNUMBER=1

until [ `cat downloadlist.txt | wc -l` -eq 0 ]
do
	mkdir "$FOLDERNUMBER"
	# take the first 100 links (if you set $FILESPERPART to 100) and put them in FOLDERNUMBER/download.txt
	cat downloadlist.txt | grep -v -e "Nutzungsbedingungen" -e 'print/section' | head -n "$FILESPERPART" > "$FOLDERNUMBER"/download.txt
	# delete the first 100 lines of the file, since we already have them in FOLDERNUMBER/downloads.txt
	cat downloadlist.txt | grep -v -e "Nutzungsbedingungen" -e 'print/section' | tail -n +"$((FILESPERPART + 1))" > downloadlist.tmp && mv downloadlist.tmp downloadlist.txt
	(
		cd "$FOLDERNUMBER"
		wget -U 'Mozilla/5.0 (X11; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0' --load-cookies "$COOKIES" -i download.txt >/dev/null 
		pdfunite `ls *.pdf | sort -n` "$FOLDERNUMBER".pdf >/dev/null 
		mv "$FOLDERNUMBER".pdf ../
		cd ..
		rm -r "$FOLDERNUMBER"
	) &
	let FOLDERNUMBER++
done
wait
echo "Assembling all files…"
pdfunite `ls *.pdf | sort -n` "$FILENAME"_unoptimized.pdf >/dev/null 
echo "Done."
echo "Optimizing PDF…"
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -sOutputFile="$FILENAME".pdf "$FILENAME"_unoptimized.pdf >/dev/null 
mv "$FILENAME".pdf ../"$FILENAME".pdf
cd ..
rm -r "$FILENAME"
echo "All done! Your book $FILENAME is ready."
