class FasterS3::Part
  attr_accessor :file_path, :index, :part_length, :extra_bytes

  def initialize(file_path, index, part_length, extra_bytes)
    self.file_path = file_path
    self.index = index
    self.part_length = part_length
    self.extra_bytes = extra_bytes
  end

  def part_path
    "#{file_path}.part.#{index}"
  end

  def byte_range
    start = index * part_length
    end_pos = start + part_length + extra_bytes

    (start + existing_size)...end_pos
  end

  def existing_size
    File.exists?(part_path) ? File.size(part_path) : 0
  end

  def download(s3_object)
    File.open(part_path, 'ab') do |file|
      s3_object.read(range: byte_range) do |chunk|
        file.write(chunk)
      end
    end
  end
end