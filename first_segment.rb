class FirstSegment
  def get_list
    # too late method

    IO.foreach("sample.txt", chomp: true).lazy
    #IO.foreach("sample_empty.txt", chomp: true).lazy
  end
end
