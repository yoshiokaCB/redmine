# Redmine

Redmine is a flexible project management web application written using Ruby on Rails framework.

More details can be found in the doc directory or on the official website http://www.redmine.org

# USE


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
$ docker-compose run --rm -e RAILS_ENV=test app rake test

```

## Delete


```

$ docker-compose down

```