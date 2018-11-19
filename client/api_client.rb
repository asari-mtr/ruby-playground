require_relative './base_client.rb'

class ApiClient < BaseClient
  # push down
  def export(file, i, total)
    FileUtils.cp(file.path, output_file_path(output_file_name(i, total)))
    "success"
  end

  # push down
  def export_from_backup(backup_file_path)
    FileUtils.cp(backup_file_path, backup_to_output_path(backup_file_path))
    "success"
  end

  # push down
  def error_process(converted_segment_list, error_index=0)
  end

  # push down
  def header

  end

  # push down
  def uuid_to_format(uuid)
    "{hgoijeifjweoijfa: #{uuid}}"
  end

  # push down
  def gzip?
    true
  end

  # push down
  def limit
    @limi_for_api ||= {
      uuid_per_request: 300_000,
      sec_per_request: 5,
      limit_size: 2_000_000,
    }
  end

  # pull up
  def name
    "facebook"
  end

  # pull up
  def id
    1234
  end

  # push down
  def output_file_name(index, total)
    if total == 1
      "hogehoge.txt.gz"
    else
      "hogehoge_#{index}.txt.gz"
    end
  end

  # push down
  def output_file_path(file_name)
    "output/#{file_name}"
  end

  # pull up
  def backup_file_path(file_name)
    "backup/#{backup_file_name(file_name)}"
  end

  # pull up
  def backup_file_name(file_name)
    "#{backup_prefix}_#{file_name}"
  end

  # pull up
  def backup_prefix
    "#{name}_#{id}"
  end

  # pull up
  def backup_file_list
    Dir.glob("backup/#{backup_prefix}_*").map { |file_path| File.open(file_path) }
  end

  # push down
  def backup_to_output_path(backup_file_name)
    orig_name = File.basename(backup_file_name).match(/^[^_]+_[^_]+_(.*)/).captures.first
    "output/#{orig_name}"
  end
end
