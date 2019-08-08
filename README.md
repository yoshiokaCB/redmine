# Redmine

Redmine is a flexible project management web application written using Ruby on Rails framework.

More details can be found in the doc directory or on the official website http://www.redmine.org

# USE

## install

```
$ git clone -b docker/virtualhost https://github.com/yoshiokaCB/redmine.git
$ cd redmine
$ git clone git://github.com/ka8725/redmine_s3.git plugins/redmine_s3
```

## Build

```
$ docker-compose build
```


## Start

```
$ docker-compose run --rm --service-ports app
```

## Test


```
# Test all
$ docker-compose run --rm -e RAILS_ENV=test app rake test

# Test specified file
$ docker-compose run --rm -e RAILS_ENV=test app rake test TEST=[path/to/file]
```

## Delete


```
$ docker-compose down
```