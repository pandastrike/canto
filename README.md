# Canto - Value Added Redis

Composed operations, data structure ligatures.


## Exports

### Cache

```coffee

log4js = require "log4js"
{Cache} = require "canto"

cache = new Cache
  log: log4js.getLogger() # optional
  namespace: "test-cache"
  ttl: 2000 # Default ttl in milliseconds
  redis:
    host: "localhost"
    port: 6379
    options: {}



cache.store {value: object}, (error, key) ->

cache.store {value: object}, (error, key) ->

cache.store object, (error, key) ->

cache.fetch key, (error, value) ->

cache.remove key, (error) ->

```

