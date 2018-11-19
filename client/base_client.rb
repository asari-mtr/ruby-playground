class BaseClient
  # public
  def export(file, i, total)
    raise NotImplementedError
  end

  # public
  def export_from_backup(backup_file_path)
    raise NotImplementedError
  end

  # push down
  def error_process(converted_segment_list, error_index=0)
  end

  # public
  def header
    raise NotImplementedError
  end

  # public
  def uuid_to_format(uuid)
    raise NotImplementedError
  end

  # public
  def gzip?
    false
  end

  # public
  def limit
    raise NotImplementedError
  end

  # public
  def output_file_name(index, total)
    raise NotImplementedError
  end

  # public
  def output_file_path(file_name)
    raise NotImplementedError
  end

  # push down
  def backup_to_output_path(backup_file_name)
    raise NotImplementedError
  end

  #
  # public
  #

  def name
    "facebook"
  end

  def id
    1234
  end

  # public
  def backup_file_list
    Dir.glob("backup/#{backup_prefix}_*").map { |file_path| File.open(file_path) }
  end

  def backup_file_path(file_name)
    "backup/#{backup_file_name(file_name)}"
  end

  private

  def backup_prefix
    "#{name}_#{id}"
  end

  def backup_file_name(file_name)
    "#{backup_prefix}_#{file_name}"
  end

end
