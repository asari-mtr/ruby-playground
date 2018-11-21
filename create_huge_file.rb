#!/usr/bin/env ruby

require 'securerandom'
require 'zlib'

if ARGV.size > 1
  puts "create_huge_file {uuid_count}"
end

uuid_count = ARGV.size == 0 ? 1_000 : ARGV[0].to_i

# ruby create_huge_file.rb  41.21s user 1.15s system 96% cpu 44.048 total
File.open("sample.txt","w+") do |f|
  uuid_count.times do |i|
    case Random.rand(2)
    when 0 then
      f.write(SecureRandom.base64(24))
    else
      f.write(SecureRandom.uuid)
    end
    f.write("\n")
  end
end

# File.open("sample.txt.gz","w") do |f|
#   zd = Zlib::GzipWriter.new(f)
#   zd << File.read("sample.txt")
#   zd.close
# end
