#!/usr/bin/env ruby

require 'securerandom'

# ruby create_huge_file.rb  41.21s user 1.15s system 96% cpu 44.048 total
File.open("sample.txt","w+") do |f|
  1_000_000.times do |i|
    f.write(i)
    f.write("\n")
  end
end
