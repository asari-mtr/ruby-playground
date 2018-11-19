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
    @client.grouped_list(uuid_list).map do |group|
      type, uuid_list = group

      log("Convert (#{i})")
      i = i + 1
      tmp = Tempfile.new

      tmp.write(@client.header(type)) if @client.header(type)
      uuid_list.each do |line|
        tmp.write(@client.uuid_to_format(line, type))
        tmp.write("\n")
      end

      [type, @client.gzip? ? gzip(tmp): tmp]
    end
  end

  def export(file_list_with_type, action)
    result = nil
    completed = true
    total = file_list_with_type.size
    file_list_with_type.each_with_index do |file_with_type, i|
      type, file = file_with_type
      file_name = action.output_file_name(i, total, type)
      begin
        file_size = file.size
        log(action.class.name)
        # log("ReExport #{file.path} (#{file_size})")
        # log("Export #{@client.output_file_path(file_name)} #{temp_file_size}")
        if file_size + @send_size > @client.limit[:limit_size_per_hour]
          action.backup(file, file_name, type)
          completed = false
          next
        end

        @send_size += file_size + @send_size

        result = action.export(file, i, total, type)
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
    result = "Not found" if file_list_with_type.size == 0
    result
  end

  class Export
    def initialize(segment)
      @segment = segment
    end

    def output_file_name(i, total, type)
      @segment.output_file_name(i, total, type)
    end

    def backup(temp_file, file_name, type)
      FileUtils.mkdir_p(@segment.backup_base_path)
      backup_file_path = @segment.backup_file_path(file_name, type)
      log("Backup to #{backup_file_path}")
      FileUtils.cp(temp_file.path, backup_file_path)
    end

    def export(file, i, total, type)
      @segment.export(file, i, total, type)
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

    def output_file_name(i, total, type)
    end

    def backup(temp_file, file_name, type)
    end

    def export(file, i, total, type)
      @segment.export_from_backup(file, type)
    end

    def post_process(file)
      File.unlink(file.path)
      Dir.rmdir(@segment.backup_base_path) if (Dir.entries(@segment.backup_base_path) - %w[ . .. ]).empty?
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
