class AwsS3

    require 'aws-sdk'

    attr_accessor :aws_profile, :aws_region, :s3_bucket, :s3_key, :s3_path, :local_path

    def initialize(aws_profile: nil, aws_region: nil, s3_bucket: nil, s3_key: nil, s3_path: nil, local_path: nil)
        @aws_profile = aws_profile
        @aws_region = aws_region
        @s3_bucket = s3_bucket
        @s3_key = s3_key
        @s3_path = s3_path
        @local_path = local_path
    end

    def create_bucket

        if (@s3_bucket.empty?) then
            abort("For an S3 bucket to be created, the name of the bucket and the AWS region need to be defined.")
        end

        counter = 0

        begin
            counter += 1
            s3 = s3_client
            s3.create_bucket(
                {
                    acl: "private",
                    bucket: @s3_bucket,
                    create_bucket_configuration: {
                            location_constraint: @aws_region
                    }
                }
            )
        rescue Errno::ETIMEDOUT => e
            retry if counter < 3
            raise
        rescue StandardError => e
            puts("#{e.class}\n#{e.message}")
            raise
        ensure
            puts("AWS Region: #{@aws_region}, S3 bucket: #{@s3_bucket}")
        end
    end

    def upload

        if (@local_path.empty? || @s3_bucket.empty? || @s3_key.empty?) then
            abort("To upload a resource on S3 the name of the S3 bucket, S3 key and the full path to the local resource need to be specified.")
        end

        counter = 0

        begin
            counter += 1
            s3 = s3_client
            File.open(@local_path, "rb") do |file|
                s3.put_object(
                    bucket: @s3_bucket,
                    key: @s3_key,
                    body: file,
                    server_side_encryption: "AES256"
                )
            end
        rescue Errno::ETIMEDOUT => e
            retry if counter < 3
            raise
        rescue StandardError => e
            puts("#{e.class}\n#{e.message}")
            raise
        ensure
            puts("AWS Region: #{@aws_region}, Local path: #{@local_path}, S3 path: #{@s3_bucket}/#{@s3_key}")
        end

    end

    def download

        if (@local_path.empty? || @s3_bucket.empty? || @s3_key.empty?) then
            abort("To download a resource from S3, the name of the S3 bucket, S3 key and the full local path where the resource is going to be stored need to be specified.")
        end

        counter = 0

        begin
            counter += 1
            s3 = s3_client
            s3.get_object({
                response_target: @local_path,
                bucket: @s3_bucket,
                key: @s3_key
            })
        rescue Errno::ETIMEDOUT => e
            retry if counter < 3
            raise
        rescue StandardError => e
            puts("#{e.class}\n#{e.message}")
            raise
        ensure
            puts("AWS Region: #{@aws_region}, S3 path: #{@s3_bucket}/#{@s3_key}, Local path: #{@local_path}")
        end

    end

    def download_last_modified

        if (@local_path.empty? || @s3_path.empty?) then
            abort("Source (full S3 path) and destination (local path) need to be specified in order to download the latest key from an S3 bucket.")
        end

        files = {}
        counter = 0
        bucket, key_prefix, latest = nil
        bucket, key_prefix = @s3_path.split("/", 2)

        s3 = s3_client
        s3.list_objects_v2({
            bucket: bucket
        }).contents.each do |k|
            files[k.last_modified] = k.key
        end

        files.sort.reverse.to_h.each do |time, file|
            if (file =~ /#{key_prefix}/)
                latest = file
                break
            end
        end

        begin
            counter += 1
            s3 = s3_client
            s3.get_object({
                response_target: @local_path,
                bucket: bucket,
                key: latest
            })
        rescue Errno::ETIMEDOUT => e
            retry if counter < 3
            raise
        rescue StandardError => e
            puts("#{e.class}\n#{e.message}")
            raise
        ensure
            puts("AWS Region: #{@aws_region}, S3 path: #{bucket}/#{latest}, Local path: #{@local_path}")
        end

    end

    private
    def load_profile
        profile = Aws::SharedCredentials.new(
            profile_name: @aws_profile,
            region: @aws_region
        )
    end

    def s3_client
        profile = load_profile
        s3 = Aws::S3::Client.new(
            region: @aws_region,
            credentials: profile.credentials
        )
    end

end
