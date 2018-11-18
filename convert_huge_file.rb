#!/usr/bin/env ruby

# ruby convert_huge_file.rb  15.91s user 1.16s system 95% cpu 17.934 total
File.open("converted.txt","w") do |desc|
  a = "hoge"
  File.open("sample.txt","r").each do |line|
    desc.write("{#{a}eifjowief:")
    desc.write(line.chomp)
    desc.write("}")
    desc.write("\n")
  end
end
