class AwsS3

    require 'aws-sdk'

    attr_accessor :aws_profile, :aws_region, :s3_bucket, :s3_key, :local_path

    def initialize(aws_profile: nil, aws_region: nil, s3_bucket: nil, s3_key: nil, local_path: nil)
        @aws_profile = aws_profile
        @aws_region = aws_region
        @s3_bucket = s3_bucket
        @s3_key = s3_key
        @local_path = local_path
    end

    def create_bucket(bucket_name, region)
        if (bucket_name.nil? || region.nil?)
            abort("Missing mandatory argument(s): bucket name, region.\nBucket creation aborted.")
        end

        counter = 0

        begin
            counter += 1
            s3 = s3_client
            s3.create_bucket(
                {
                    acl: "private",
                    bucket: bucket_name,
                    create_bucket_configuration: {
                            location_constraint: region
                    }
                }
            )
            puts("Bucket '#{bucket_name}' created successfully in '#{region}'.")
        rescue Errno::ETIMEDOUT => e
            retry if counter < 3
            raise
        rescue StandardError => e
            puts("Exception details:\n\t#{e.class}\n\t#{e.message}")
            raise
        ensure
            puts("Region => #{region},\nBucket => #{bucket_name}")
        end
    end

    def upload(path, key)
        if (key.nil? || path.nil?)
            abort("Missing mandatory argument(s): S3 key, local path.\nUpload aborted.")
        end

        bucket, s3_key = key.split("/", 2)
        counter = 0

        begin
            counter += 1
            s3 = s3_client
            File.open(path, "rb") do |file|
                s3.put_object(
                    bucket: bucket,
                    key: s3_key,
                    body: file,
                    server_side_encryption: "AES256"
                )
            end
            puts("Upload completed.")
        rescue Errno::ETIMEDOUT => e
            retry if counter < 3
            raise
        rescue StandardError => e
            puts("Exception details:\n\t#{e.class}\n\t#{e.message}")
            raise
        ensure
            puts("Region => #{@aws_region},\nKey => #{key},\nPath => #{path}")
        end
    end

    def download(key, path)
        if (key.nil? || path.nil?)
            abort("Missing mandatory argument(s): S3 key, local path.\nDownload aborted.")
        end

        bucket, s3_key = key.split("/", 2)
        counter = 0

        begin
            counter += 1
            s3 = s3_client
            s3.get_object({
                response_target: path,
                bucket: bucket,
                key: s3_key
            })
            puts("Download successful.")
        rescue Errno::ETIMEDOUT => e
            retry if counter < 3
            raise
        rescue Aws::S3::Errors::NoSuchKey => e
            puts("Encountered the following exception:\n\t#{e.class}\n\t#{e.message}")
            puts("Assuming a key was deliberate not specified.\nDownloading the latest key from the specified bucket.")
            puts("If this is not desired, cancel now; download will begin in a few seconds...")
            sleep(3)
            files = {}
            latest = nil
            s3 = s3_client
            s3.list_objects_v2({
                bucket: bucket
            }).contents.each do |k|
                files[k.last_modified] = k.key
            end

            files.sort.reverse.to_h.each do |time, file|
                if (file =~ /#{s3_key}/)
                    latest = file
                    break
                end
            end

            begin
                puts("Downloading '#{key}/#{latest}' instead...")
                counter += 1
                s3 = s3_client
                s3.get_object({
                    response_target: path,
                    bucket: bucket,
                    key: latest
                })
                puts("Download successful.")
            rescue Errno::ETIMEDOUT => e
                retry if counter < 3
                raise
            rescue StandardError => e
                puts("Exception details:\n\t#{e.class}\n\t#{e.message}")
                raise
            end
        rescue StandardError => e
            puts("Exception details:\n\t#{e.class}\n\t#{e.message}")
            raise
        ensure
            puts("Region => #{@aws_region},\nKey => #{key},\nPath => #{path}")
        end
    end

    def presign_url(bucket, key, ttl)
        url = s3_presigner.presigned_url(
            :get_object,
            params = {
                bucket: bucket,
                key: key,
                expires_in: ttl
            }
        )
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

    def s3_presigner
        presigner = Aws::S3::Presigner.new(
            client: s3_client
        )
    end

end
