require_relative './base_client.rb'

class SftpClient < BaseClient
  def export(file, i, total, type)
    FileUtils.cp(file.path, output_file_path(output_file_name(i, total, type)))
    "success"
  end

  def export_from_backup(backup_file, type)
    FileUtils.cp(backup_file.path, backup_to_output_path(backup_file.path))
    "success"
  end

  # push down
  def limit
    @limi_for_api ||= {
      uuid_per_request: 300_000,
      sec_per_request: 5,
      limit_size_per_hour: 2_000_000,
    }
  end

  def uuid_to_format(uuid, type)
    "{hgoijeifjweoijfa: #{uuid}}"
  end

  def gzip?
    true
  end

  def output_file_name(index, total, type)
    if total == 1
      "hogehoge.txt.gz"
    else
      "hogehoge_#{index}.txt.gz"
    end
  end

  private

  def output_file_path(file_name)
    "output/#{file_name}"
  end

  def backup_to_output_path(backup_file_name)
    orig_name = original_file_from_backup_file_name(backup_file_name)
    "output/#{orig_name}"
  end
end
