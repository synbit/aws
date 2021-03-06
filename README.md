# aws
Collection of AWS related stuff

## Examples

### s3.rb

#### Upload to S3

POSIX-style options can be used:
```shell
ruby s3.rb --upload --aws-profile=your_profile --aws-region=your_region --s3-key=bucket-name/key-prefix/key --local-path=/local/path/my.key
```
or, single letter options:
```shell
ruby s3.rb -u -i your_profile -r your_region -k bucket-name/key-prefix/key -p /local/path/my.key
```
#### Download from S3

```shell
ruby s3.rb --download --aws-profile=your_profile --aws_region=your_region --s3-key=bucket-name/key-prefix/key --local-path=/local/path/my.key
```
#### Create a bucket

```shell
ruby s3.rb --create-bucket --aws-profile=your_profile --aws-region=your_region --s3-bucket=bucket_name
```
### presigner.rb

#### Generate presigned URLs for the specified S3 resources and set their expiry time
```shell
ruby presigner.rb --aws-profile=your_profile --aws-region=your_region --s3-bucket=bucket_name --s3-key=key_name --expiry-time=3600
```
### non-elb-instances.rb

#### Find all instances in a given region that are not member of an Elastic Load Balancer
```shell
ruby non-elb-instances.rb
```
