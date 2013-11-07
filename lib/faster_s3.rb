require "faster_s3/version"
require "faster_s3/part"
require "faster_s3/download"

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
    Download.new(destination, options).download
  end

end