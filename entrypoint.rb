#!/usr/local/bin/ruby

require 'aws-sdk'

APP_HOME="/var/lib/redmine"

# 初期設定
res = Aws::S3::Resource.new(
  region: 'ap-northeast-1',
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
)

bucket_name = 'apache-config-files-20190708'
if res.bucket(bucket_name).exists?
  bucket = res.bucket(bucket_name)
  bucket.objects.each do |object|

    # ファイル保存
    # "/etc/apache2/conf-available/"
    file_name = object.key.split('/').last
    # bucket.object(object.key).get(response_target: "./download/#{file_name}")
    bucket.object(object.key).get(response_target: "/etc/apache2/conf-available/#{file_name}")

    # シンボリックリンク
    # ln -s $APP_HOME "/var/lib/rm${COUNT}"
    dir_name = file_name.split('.')[0]
    system( "ln -s #{APP_HOME} \"/var/lib/#{dir_name}\"" )

    # Apache有効化
    system( "a2enconf #{dir_name}" )
  end
end
