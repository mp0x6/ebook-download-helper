require 'digest'
require 'pp'

# get the first argument and set it to foldername
foldername = ARGV[0]
# get all entrys in the directory that are not a directory
files_in_folder = Dir.entries(foldername).reject { |f| File.directory? f}
files_in_folder = files_in_folder.select do |elem|
  # ensure all files checked are in fact .bmps
  File.extname(elem) == '.bmp'
end

hashed_files = Array.new
files_in_folder.each() { |file|
  # generate a full path with filename
  filename = foldername + file
  hash_of_file = Digest::SHA256.file filename
  # since comparing the objects doesn't work somehow, we have to save the hash as a hex instead
  hash_of_file_hex = hash_of_file.hexdigest
  # generate a 2x1 array and push it into the existing array outside of the loop
  filename_hash_pair = [filename, hash_of_file_hex]
  hashed_files << filename_hash_pair
}

# only return unique entries of the hashed_files array based on the second entry in its child arrays
files_without_dupes = hashed_files.uniq {|s| s[1]}

# cycle through files_without_dupes and output the first entry of the array (the filename) to stdout
files_without_dupes.each { |file|
  puts file.first
}
