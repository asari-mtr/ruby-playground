class BaseClient

  #
  # for common
  #

  def id
    # generate
    1234
  end

  def name
    self.class.name.downcase
  end

  def error_process(converted_segment_list, error_index=0)
  end

  def limit
    @limi_for_api ||= {
      uuid_per_request: 1_000_000,
      sec_per_request: 5,
      limit_size_per_hour: 5_000_000_000,
    }
  end

  #
  # for convert
  #
  def grouped_list(uuid_list)
    uuid_list.each_slice(limit[:uuid_per_request]).map do |uuid_list_per_request|
      [:uuid, uuid_list_per_request]
    end
  end

  #
  # for export
  #

  def export(file, i, total)
    raise NotImplementedError
  end

  def export_from_backup(backup_file_path)
    raise NotImplementedError
  end

  def header(type)
  end

  def uuid_to_format(uuid, type)
    uuid
  end

  def gzip?
    false
  end

  def output_file_name(index, total, type)
    "#{type}_#{name}_#{index}.dat"
  end

  #
  # for backup
  #

  def backup_file_list
    Dir.glob("#{backup_base_path}/#{backup_prefix}_*").map do |file_path|
      type = File.basename(file_path).match(/^#{backup_prefix}_([^_])+_.*/).captures.first
      [type, File.open(file_path)]
    end
  end

  def backup_file_path(file_name, type)
    "#{backup_base_path}/#{backup_file_name(file_name, type)}"
  end

  def backup_base_path
    "backup/#{name}_#{id}"
  end

  private

  def backup_prefix
    "backup"
  end

  def backup_file_name(file_name, type)
    "#{backup_prefix}_#{type}_#{file_name}"
  end

  def original_file_from_backup_file_name(backup_file_name)
    File.basename(backup_file_name).match(/^#{backup_prefix}_[^_]+_(.*)/).captures.first
  end

end
