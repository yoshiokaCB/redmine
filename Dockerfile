FROM ruby:2.6-slim-stretch

ENV LANG C.UTF-8
ENV REDMINE_LANG ja
ENV APP_HOME /var/lib/redmine

ENV DEBIAN_FRONTEND noninteractive
RUN set -eux; \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
		\
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
		gsfonts \
		imagemagick libmagick++-dev \
		build-essential \
    libpq-dev \
    default-libmysqlclient-dev \
    ; \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*;
ENV DEBIAN_FRONTEND dialog


# RUN apt-get update && \
#   : "必要ライブラリーのインストール" && \
#   apt-get install -y \
#   task-japanese \
#   build-essential zlib1g-dev libssl-dev libreadline-dev libyaml-dev libcurl4-openssl-dev libffi-dev \
#   imagemagick libmagick++-dev \
#   subversion tzdata libpq-dev && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/* \
#   \
#   : "日本語対応" && \
#   locale-gen ja_JP.UTF-8;

#   language-pack-ja \
#   imagemagick libmagick++-dev fonts-takao-pgothic \

WORKDIR $APP_HOME
VOLUME $APP_HOME
ADD . $APP_HOME

RUN : "仮のdatabase.ymlを作成" && { \
    echo "production:"; \
    echo "  adapter: <%= ENV['RAILS_DB_ADAPTER'] %>"; \
    echo "  database: <%= ENV['RAILS_DB'] %>"; \
    echo "  username: <%= ENV['RAILS_DB_USERNAME'] %>"; \
    echo "  password: <%= ENV['RAILS_DB_PASSWORD'] %>"; \
    echo "  host: <%= ENV['RAILS_DB_HOST'] %>"; \
    echo "  encoding: <%= ENV['RAILS_DB_ENCODING'] %>"; \
    echo "development:"; \
    echo "  adapter: <%= ENV['RAILS_DB_ADAPTER'] %>"; \
    echo "  database: <%= ENV['RAILS_DB'] %>_development"; \
    echo "  username: <%= ENV['RAILS_DB_USERNAME'] %>"; \
    echo "  password: <%= ENV['RAILS_DB_PASSWORD'] %>"; \
    echo "  host: <%= ENV['RAILS_DB_HOST'] %>"; \
    echo "  encoding: <%= ENV['RAILS_DB_ENCODING'] %>"; \
    echo "test:"; \
    echo "  adapter: <%= ENV['RAILS_DB_ADAPTER'] %>"; \
    echo "  database: <%= ENV['RAILS_DB'] %>_test"; \
    echo "  username: <%= ENV['RAILS_DB_USERNAME'] %>"; \
    echo "  password: <%= ENV['RAILS_DB_PASSWORD'] %>"; \
    echo "  host: <%= ENV['RAILS_DB_HOST'] %>"; \
    echo "  encoding: <%= ENV['RAILS_DB_ENCODING'] %>"; \
  } | tee /var/lib/redmine/config/database.yml;


COPY ./start.sh /
COPY ./entrypoint.sh /
RUN chmod +x /start.sh && \
  chmod +x /entrypoint.sh && \
  bundle install

# ENV RAILS_ENV production
# COPY ./docker-entrypoint.sh /
# COPY ./docker-entrypoint.rb /
# RUN chmod +x /docker-entrypoint.sh && chmod +x /docker-entrypoint.rb


EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]
# CMD ["irb"]
