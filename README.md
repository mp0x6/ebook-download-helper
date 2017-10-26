# ebook-download-helper

This project helps you to download a large amount of __ordered__ PDF-files from a remote server, downloads, joins and optimizes them.

You'll need a list of the links to the PDF files comprising your book. If you're using Google Chrome, you might want to use [Link Klippr](https://chrome.google.com/webstore/detail/link-klipper-extract-all/fahollcgofmpnehocdgofnhkkchiekoo).
Configure it to use "TXT" as output format, set "Multiple Extensions" to "pdf" and activate the option.

After that, you're good to go.

## Usage

```bash
./ebook-download-helper link-list.txt "Name of the Book"
```

## Requirements
You'll need a UNIX-like OS in order to execute this script.

macOS High Sierra is my personal target platform, but it should work on Linux and other UNIX-like OS'es without any hassle.

You'll need the following packages:

- Ghostscript
- wget
- poppler
- grep

## Installation
On macOS, I recommend the installation of the dependencies via [https://brew.sh](Homebrew). On other platforms, use the package manager of your personal preference. On the command-line, enter the following command (with homebrew installed):
```bash
brew install ghostscript wget poppler grep git
```

After that, you can clone this respository using git:
```bash
git clone https://github.com/mp0x6/ebook-download-helper.git
```

Change in the directory of the script and execute it, either by running
```bash
bash ebook-download-helper link-list.txt "Name of the Book"
```
or
```bash
./ebook-download-helper link-list.txt "Name of the Book"
```
