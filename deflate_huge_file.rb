#!/usr/bin/env ruby

# ruby convert_huge_file.rb  15.91s user 1.16s system 95% cpu 17.934 total
require 'zlib'

z = Zlib::Deflate.new

File.open("converted3.txt.gz","w") do |desc|
  a = "hoge"
  File.open("sample.txt","r").each do |line|
    desc << z.deflate("{#{a}eifjowief:#{line.chomp}}\n", Zlib::NO_FLUSH)
  end
end
