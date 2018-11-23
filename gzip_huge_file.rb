#!/usr/bin/env ruby

# ruby convert_huge_file.rb  15.91s user 1.16s system 95% cpu 17.934 total
require 'zlib'

def gzip(src, dest)
  chunk_size = 64 * 1024 * 1024

  File.open(src) do |f|
    Zlib::GzipWriter.open(File.open(dest, "w")) do |w|
      w.write(f.read(chunk_size)) until f.eof?
    end
  end
end

def ungzip(src, dest)
  chunk_size = 64 * 1024 * 1024

  Zlib::GzipReader.open(File.open(src, "r")) do |r|
    File.open(dest, 'w') do |f|
      f.write(r.read(chunk_size)) until r.eof?
    end
  end
end

gzip('converted.txt', 'converted.txt.gz')
ungzip('converted.txt.gz', 'converted.txt.gz.txt')
