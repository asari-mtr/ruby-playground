class BaseClient

  def export(file, i, total)
    raise NotImplementedError
  end

  def export_from_backup(backup_file_path)
    raise NotImplementedError
  end

  def limit
    @limi_for_api ||= {
      uuid_per_request: 1_000_000,
      sec_per_request: 5,
      limit_size_per_hour: 5_000_000_000,
    }
  end

  def header
  end

  def uuid_to_format(uuid)
    uuid
  end

  def gzip?
    false
  end

  def output_file_name(index, total)
    "#{name}_#{index}.dat"
  end

  def error_process(converted_segment_list, error_index=0)
  end

  def name
    self.class.name.downcase
  end

  def id
    # generate
    1234
  end

  def backup_file_list
    Dir.glob("#{backup_base_path}/#{backup_prefix}_*").map { |file_path| File.open(file_path) }
  end

  def backup_file_path(file_name)
    "#{backup_base_path}/#{backup_file_name(file_name)}"
  end

  def backup_base_path
    "backup_#{name}"
  end

  private

  def backup_prefix
    "#{name}_#{id}"
  end

  def backup_file_name(file_name)
    "#{backup_prefix}_#{file_name}"
  end

end
