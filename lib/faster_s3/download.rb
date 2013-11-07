require 'aws/s3'
require 'parallel'

module FasterS3
  class Download
    DEFAULT_PARTS = 8
    CHUNK_SIZE = 1024*1024

    attr_reader :target_path, :config, :parts

    def initialize(target_path, config = {})
      @target_path = target_path
      @config = config
      @parts = config[:parallel] || DEFAULT_PARTS
    end

    def download
      reconstitute(download_parts)
    end

    def download_parts
      part_objects = create_parts
      Parallel.map(part_objects, in_threads: part_objects.length) do |file_part|
        file_part.download(s3_object)
        file_part.part_path
      end
    end

    def create_parts
      length = s3_object.content_length
      raise "File is too small to download in parallel" if length < parts

      # Split into parts
      part_length = length / parts
      remainder = length % parts

      part_objects = []
      parts.times do |index|
        # Last part includes any remaining bytes
        extra_bytes = (index == (parts - 1)) ? remainder : 0
        part_objects << Part.new(target_path, index, part_length, extra_bytes)
      end

      part_objects
    end

    def reconstitute(file_parts)
      File.open(target_path, 'wb') do |file|
        file_parts.each do |part_path|
          File.open(part_path, 'rb') do |part_file|
            file.write(part_file.read(CHUNK_SIZE)) until part_file.eof?
          end
          File.delete(part_path)
        end
      end
    end

    private

    def s3_object
      @s3_object ||= begin
        s3 = AWS::S3.new({:access_key_id => config[:access_key_id], :secret_access_key => config[:secret_access_key]})
        bucket = s3.buckets[config[:bucket_name]]
        bucket.objects[config[:path]]
      end
    end
  end
end