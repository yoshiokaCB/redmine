#!/usr/local/bin/ruby

require 'aws-sdk'
require 'yaml'

def generate_apache_config(sub_domain, db_name, db_user, rails_env, db_password)
  conf = <<-eos
<VirtualHost *:80>
  ServerName #{sub_domain}.dev.cloudz-0211.work
  ServerAdmin webmaster@localhost
  DocumentRoot /var/lib/#{db_name}/public
  ErrorLog /var/log/apache2/error.log
  CustomLog /var/log/apache2/access.log vhost_combined
  RailsEnv #{rails_env}
  PassengerEnabled on
  SetEnv RAILS_DB #{db_name}
  SetEnv RAILS_DB_USERNAME #{db_user}
  SetEnv RAILS_DB_PASSWORD #{db_password}
  SetEnv S3_FOLDER_NAME #{db_name}-files
  <Directory /var/lib/#{db_name}/public>
    Require all granted
  </Directory>
</VirtualHost>
  eos

  conf
end

APP_HOME="/var/lib/redmine"

# 初期設定
res = Aws::S3::Resource.new(
  region: 'ap-northeast-1',
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
)

bucket_name = ENV['CONFIG_BUCKET_NAME']

if res.bucket(bucket_name).exists?
  bucket = res.bucket(bucket_name)
  bucket.objects.each do |object|

    # ファイル名生成（xxxx.conf)
    # WEBサーバ(apache2)のコンフィグファイル生成
    # 設定情報はymlで取得
    # trunkかstableのバージョンも取得
    # バージョンによってシンボリックリンクの参照先を変更
    conf = YAML.load(object.get.body.read)
    p conf

    sub_domain  = conf["property"]["sub_domain"]
    db_name     = conf["db"]["name"]
    db_user     = conf["db"]["user"]
    db_password = conf["db"]["password"]
    rails_env   = conf["property"]["rails_env"]

    apache_conf = generate_apache_config(sub_domain, db_name, db_user, rails_env, db_password)

    # ファイル保存
    File.open("/etc/apache2/conf-available/#{db_name}.conf", "w") {|f| f.puts(apache_conf)}

    # シンボリックリンク
    # configのファイル名をディレクトリー名として利用
    system( "ln -s #{APP_HOME} \"/var/lib/#{db_name}\"" )
    system( "mkdir -p #{APP_HOME}/log/#{db_name}" )

    # Apache有効化
    system( "a2enconf #{db_name}" )
  end
end
