Testify = require "testify"
assert = require "assert"

Cache = require "../src/lru_cache"

cache = new Cache
  log:
    error: ->
    debug: ->
    warn: ->

  namespace: "test-cache"
  size: 5
  redis:
    host: "localhost"
    port: 6379
    options: {}

Testify.once "done", -> process.exit()

Testify.test "LRU Cache", (context) ->

  context.test ".store", (context) ->
    cache.store {zoo: "cages"}, (error, key) ->


