#!/usr/bin/env ruby

# ruby convert_huge_file2.rb  15.16s user 1.20s system 95% cpu 17.141 total
sample = IO.foreach("sample.txt",chomp: true).lazy

File.open("converted2.txt","w") do |desc|
  a = "hoge"
  sample.each do |line|
    desc.write("{#{a}eifjowief:")
    desc.write(line.chomp)
    desc.write("}")
    desc.write("\n")
  end
end
