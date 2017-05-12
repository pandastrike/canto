# Canto - Value Added Redis

> **Important** This project is deprecated and unsupported.

Composed operations, data structure ligatures.

## Install

    npm install --save canto

## Included classes

### Cache

```coffee

log4js = require "log4js"
{Cache} = require "canto"

cache = new Cache
  log: log4js.getLogger() # optional
  # Because we need to expire them, items are stored as Redis strings.
  # To avoid polluting the global keyspace, we always prefix a namespace
  # to our keys.  The namespace defaults to "cache"
  namespace: "test-cache/"
  # Default ttl in milliseconds
  # If not set, then items will only be expired when
  # put is called with a ttl.
  ttl: 2000
  redis:
    host: "localhost"
    port: 6379
    options: {}



# storing
cache.put {key: "red", value: object, ttl: 5 * 1000}, (error) ->
cache.put {key: "blue", value: object}, (error) ->

# retrieving
cache.get key, (error, value) ->

# deleting
cache.delete key, (error) ->

```

