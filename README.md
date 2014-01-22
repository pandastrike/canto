# Canto - Value Added Redis

Composed operations, data structure ligatures.


## Included classes

### Cache

```coffee

log4js = require "log4js"
{Cache} = require "canto"

cache = new Cache
  log: log4js.getLogger() # optional
  namespace: "test-cache"
  # Default ttl in milliseconds
  # If not set, then items will only be expired when
  # store is called with a ttl.
  ttl: 2000
  redis:
    host: "localhost"
    port: 6379
    options: {}



# storing
cache.store {value: object, ttl: 5 * 1000}, (error, key) ->
cache.store {value: object}, (error, key) ->
cache.store object, (error, key) ->

# fetching
cache.fetch key, (error, value) ->

# removing
cache.remove key, (error) ->

```

