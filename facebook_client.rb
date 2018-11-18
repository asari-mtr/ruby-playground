class FacebookClient
  def export(segment_list, index, total)
    if total == 1
      FileUtils.cp(segment_list.path, output_file_name)
    # elsif index == 2
    #   raise ArgumentError.new("fail")
    else
      FileUtils.cp(segment_list.path, output_file_name(index))
    end
    "success"
  end

  def info_for_send(index, total)
    {
      output_file: output_file_name(index)
    }
  end

  def error_process(converted_segment_list, error_index)
  end

  def header

  end

  def uuid_to_format(uuid)
    "{hgoijeifjweoijfa: #{uuid}}"
  end

  def gzip?
    false
  end

  def limit
    @limi_for_api ||= {
      uuid_per_request: 3_000_000,
      sec_per_request: 5
    }
  end

  def output_file_name(index=nil)
    if index
      "output/hogehoge_#{index}.txt.gz"
    else
      "output/hogehoge.txt.gz"
    end
  end
end
