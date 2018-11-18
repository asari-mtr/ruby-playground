require 'zlib'
require 'tempfile'
require 'securerandom'
require_relative './first_segment.rb'
require_relative './facebook_client.rb'

class Etl
  # dest is facebook, twitter, instagram ...
  def initialize(origin, fb)
    @origin = origin
    @fb = fb
  end

  def execute
    result = "something error"
    begin
      log("start to get list")
      uuid_list = @origin.get_list

      log("start to convert")
      converted_segment_list = convert(uuid_list)

      log("start to export")
      result = export(converted_segment_list)
    rescue => e
      result = e.message
      raise e
    ensure
      log("result: #{result}")
    end
  end

  def log(str)
    puts "#{Time.now.strftime('%Y/%m/%d %H:%M:%S')} #{str}"
  end

  def notify(str)
    log(str)
    # TODO: notify
  end

  def convert(uuid_list)
    i = 0
    uuid_list.each_slice(@fb.limit[:uuid_per_request]).map do |list|
      log("Convert (#{i})")
      i = i + 1
      tmp = Tempfile.new

      tmp.write(@fb.header) if @fb.header
      list.each do |line|
        tmp.write(@fb.uuid_to_format(line))
        tmp.write("\n")
      end

      @fb.gzip? ? gzip(tmp): tmp
    end
  end

  def export(converted_segment_list)
    result = nil
    converted_segment_list.each_with_index do |segment_list, i|
      total = converted_segment_list.size
      begin
        log("Export #{i}")
        result = @fb.export(segment_list,i ,total)
        break if result != "success"

        sleep (1.0 / @fb.limit[:sec_per_request])
      rescue => e
        error_handler_for_send(e, segment_list, i, total)
        @fb.error_process(converted_segment_list, i)
      end
    end
    result = "Not found" if converted_segment_list.size == 0
    result
  end

  def error_handler_for_send(e, file, i, total)
      filename = SecureRandom.hex
      # slackにも通知
      notify(@fb.info_for_send(i, total))
      notify(filename)
      error_file_path = "error/#{filename}"
      FileUtils.mkdir_p("error")
      FileUtils.cp(file.path, error_file_path)

      raise e
  end

  def gzip(file)
    tmp = Tempfile.new
    Zlib::GzipWriter.open(tmp) do |gw|
      gw << File.read(file)
    end
    tmp
  end
end

Etl.new(FirstSegment.new, FacebookClient.new).execute
