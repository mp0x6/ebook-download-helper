require 'digest'
require 'pp'

foldername = ARGV[0]
# foldername = './.tmp'
files_in_folder = Dir.entries('./.tmp').reject { |f| File.directory? f}
files_in_folder = files_in_folder.select do |elem|
  File.extname(elem) == '.bmp'
end

hashed_files = Array.new
files_in_folder.each() { |file|
  filename = foldername + file
  hash_of_file = Digest::SHA256.file filename
  hash_of_file_hex = hash_of_file.hexdigest
  filename_hash_pair = [filename, hash_of_file_hex]
  hashed_files << filename_hash_pair
}

files_without_dupes = hashed_files.uniq {|s| s[1]}

files_without_dupes.each { |file|
  puts file.first
}