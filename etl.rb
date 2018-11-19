require 'zlib'
require 'tempfile'
require 'securerandom'
require_relative './first_segment.rb'
require_relative './client/sftp_client.rb'
require_relative './client/api_client.rb'

class Etl
  # dest is facebook, twitter, instagram ...
  def initialize(origin, client)
    @origin = origin
    @client = client
    @send_size = 0
  end

  def execute
    result = "something error"
    begin
      backup_file_list = @client.backup_file_list
      if backup_file_list.empty?
        log("start to get list")
        uuid_list = @origin.get_list
        if uuid_list.count == 0
          return result = "Empty"
        end

        log("start to convert")
        converted_file_list = convert(uuid_list)

        log("start to export")
        # result = export(converted_file_list)
        result = export(converted_file_list, Export.new(@client))
      else
        log("start to reexport")
        # result = reexport(backup_file_list)
        result = export(backup_file_list, ReExport.new(@client))
      end
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
    uuid_list.each_slice(@client.limit[:uuid_per_request]).map do |list|
      log("Convert (#{i})")
      i = i + 1
      tmp = Tempfile.new

      tmp.write(@client.header) if @client.header
      list.each do |line|
        tmp.write(@client.uuid_to_format(line))
        tmp.write("\n")
      end

      @client.gzip? ? gzip(tmp): tmp
    end
  end

  def export(file_list, action)
    result = nil
    completed = true
    total = file_list.size
    file_list.each_with_index do |file, i|
      file_name = action.output_file_name(i, total)
      begin
        file_size = file.size
        log(action.class.name)
        # log("ReExport #{file.path} (#{file_size})")
        # log("Export #{@client.output_file_path(file_name)} #{temp_file_size}")
        if file_size + @send_size > @client.limit[:limit_size]
          action.backup(file, file_name)
          completed = false
          next
        end

        @send_size += file_size + @send_size

        result = action.export(file, i, total)
        break if result != "success"

        action.post_process(file)

        sleep (1.0 / @client.limit[:sec_per_request])
      rescue => e
        log(e.message)
        raise e
        # error
        # error_handler_for_export(e, file)
        # @client.error_process(backup_file_list)
      end
    end
    # perform_later
    raise "Incomplete" unless completed
    # TODO: Check here?
    result = "Not found" if file_list.size == 0
    result
  end

  class Export
    def initialize(segment)
      @segment = segment
    end

    def output_file_name(i, total)
      @segment.output_file_name(i, total)
    end

    def backup(temp_file, file_name)
      backup_file_path = @segment.backup_file_path(file_name)
      log("Backup to #{backup_file_path}")
      FileUtils.cp(temp_file.path, backup_file_path)
    end

    def export(file, i, total)
      @segment.export(file, i, total)
    end

    def post_process(file)
    end

    private
    # TODO: duplicate
    def log(str)
      puts "#{Time.now.strftime('%Y/%m/%d %H:%M:%S')} #{str}"
    end
  end

  class ReExport
    def initialize(segment)
      @segment = segment
    end

    def output_file_name(i, total)
    end

    def backup(temp_file, file_name)
    end

    def export(file, i, total)
      @segment.export_from_backup(file)
    end

    def post_process(file)
      File.unlink(file.path)
    end

    private
    # TODO: duplicate
    def log(str)
      puts "#{Time.now.strftime('%Y/%m/%d %H:%M:%S')} #{str}"
    end
  end


  # def error_handler_for_send(e, file, i, total)
  #     filename = SecureRandom.hex
  #     # slackにも通知
  #     notify(@client.info_for_send(i, total))
  #     notify(filename)
  #     error_file_path = "error/#{filename}"
  #     FileUtils.mkdir_p("error")
  #     FileUtils.cp(file.path, error_file_path)

  #     raise e
  # end

  def error_handler_for_export(e, file_path)
      filename = SecureRandom.hex
      # slackにも通知
      notify(filename)
      error_file_path = "error/#{filename}"
      FileUtils.mkdir_p("error")
      FileUtils.cp(file_path, error_file_path)

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

Etl.new(FirstSegment.new, SftpClient.new).execute
