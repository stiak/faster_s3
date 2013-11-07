# FasterS3

Download files from s3 faster by downloading chunks in parallel

## Installation

Add this line to your application's Gemfile:

    gem 'faster_s3'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faster_s3

## Usage

FasterS3.download(
        "path_to_local_file",
        access_key_id: "s3 access key id",
        secret_access_key: "s3 secret access key",
        bucket_name: "s3-bucket",
        path: "path-in-s3"
        )


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
