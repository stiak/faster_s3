require "faster_s3/version"
require 'aws/s3'
require 'parallel'

module FasterS3
  # @param [String] destination File will be written to this destination
  # @param [Hash] options
  #
  # @option options [String] :access_key_id The access key id for the s3 account
  #
  # @option options [String] :secret_access_key The secret access key for the s3 account
  #
  # @option options [String] :bucket_name The s3 bucket name
  #
  # @option options [String] :path The path in s3 of the file
  #
  # @option options [String] :parallel Optional - number of parallel parts to download.  Default is 8
  #
  def self.download(destination, options)
    Download.new(options).download_to(destination)
  end

  class Download
    DEFAULT_PARTS = 8
    CHUNK_SIZE = 1024*1024

    attr_reader :config, :parts

    def initialize(config = {})
      @config = config
      @parts = config[:parallel] || DEFAULT_PARTS
    end

    def download_to(path)
      s3_object = remote_object
      length = s3_object.content_length
      raise "File is too small to download in parallel" if length < parts

      # Split into parts
      part_length = length / parts
      remainder = length % parts

      part_array = Array(1..parts)
      file_parts = Parallel.map(part_array, in_threads: parts) do |part|
        start = (part - 1) * part_length
        end_pos = start + part_length

        if part == part_array.last
          end_pos += remainder
          byte_range = start..end_pos
        else
          byte_range = start...end_pos
        end

        part_path = "#{path}.part.#{part}"
        File.open("#{path}.part.#{part}", 'wb') do |file|
          s3_object.read(range: byte_range) do |chunk|
            file.write(chunk)
          end
        end
        part_path
      end

      reconstitute_parts(path, file_parts)
    end

    def reconstitute_parts(path, file_parts)
      File.open(path, 'wb') do |file|
        file_parts.each do |part_path|
          File.open(part_path, 'rb') do |part_file|
            file.write(part_file.read(CHUNK_SIZE)) until part_file.eof?
          end
          File.delete(part_path)
        end
      end
    end

    def remote_object
      s3 = AWS::S3.new({:access_key_id => config[:access_key_id], :secret_access_key => config[:secret_access_key]})
      bucket = s3.buckets[config[:bucket_name]]
      bucket.objects[config[:path]]
    end
  end

end