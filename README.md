# aws
Collection of AWS related stuff

## Examples

### s3.rb
POSIX-style options can be used:
```shell
ruby s3.rb --action=upload --aws-profile=your_profile --aws-region=your_region --s3-bucket=your_bucket_name --s3-key=your/valuable/key --local-path=/full/path/to/local/resource
```
or, single letter options:
```shell
ruby s3.rb -a upload -i your_profile -r your_region -b your_bucket_name -k your/valuable/key -p /full/path/to/local/resource
```
