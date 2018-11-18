#!/usr/bin/env ruby

# ruby convert_huge_file.rb  15.91s user 1.16s system 95% cpu 17.934 total
require 'zlib'

File.open("converted.txt.gz", "w") do |f|
  zd = Zlib::GzipWriter.new(f)
  zd << File.read("converted.txt")
end
