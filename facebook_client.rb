class FacebookClient
  def export(file, output_file_name)
    FileUtils.cp(file.path, output_file_path(output_file_name))
    "success"
  end

  def export_from_backup(backup_file_path)
    FileUtils.cp(backup_file_path, backup_to_output_path(backup_file_path))
    "success"
  end

  # def info_for_send(index, total)
  #   {
  #     output_file: output_file_name(index, total),
  #     output_path: output_file_path(index, total)
  #   }
  # end

  # def info_for_reexport(backup_file_path)
  #   {
  #     backup_file_path: backup_file_path
  #   }
  # end

  def error_process(converted_segment_list, error_index=0)
  end

  def header

  end

  def uuid_to_format(uuid)
    "{hgoijeifjweoijfa: #{uuid}}"
  end

  def gzip?
    true
  end

  def limit
    @limi_for_api ||= {
      uuid_per_request: 3_000_000,
      sec_per_request: 5,
      limit_size: 20_000_000,
    }
  end

  def output_file_name(index, total)
    if total == 1
      "hogehoge.txt.gz"
    else
      "hogehoge_#{index}.txt.gz"
    end
  end

  def name
    "facebook"
  end

  def id
    1234
  end

  def output_file_path(output_file_name)
    "output/#{output_file_name}"
  end

  def backup_file_path(output_file_name)
    "backup/#{backup_file_name(output_file_name)}"
  end

  def backup_file_name(output_file_name)
    "#{name}_#{id}_#{output_file_name}"
  end

  def backup_file_list
    Dir.glob("backup/#{name}_#{id}_*").map { |file_path| File.open }
  end

  def backup_to_output_path(backup_file_name)
    orig_name = File.basename(backup_file_name).match(/^[^_]+_[^_]+_(.*)/).captures.first
    "output/#{orig_name}"
  end
end
