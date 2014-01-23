redis = require "redis"
log4js = require "log4js"
{randomKey} = require "key-forge"

# NOTE: If using an individual Redis instance for caching, there's a better
# solution: http://redis.io/topics/config
#
# This class is useful as an LRU cache when you want to use a single Redis
# instance, or when you want more visibility into the cache storage for
# development and debugging purposes.  It is necessarily slower than the
# use of a dedicated Redis instance for caching.
module.exports = class LRUCache

  constructor: (@configuration) ->
    {@log, @size, @namespace, redis: {host, port, options}} = @configuration

    @log ?= log4js.getLogger("Cache")
    @size ?= 65536
    @namespace ?= "lru-cache"
    @keys =
      index: "#{@namespace}/index"
      storage: "#{@namespace}/store"

    @redis = redis.createClient port, host, options
    @redis.on "error", (error) =>
      @log.error "Problem with Redis: #{error}"

  store: (value, callback) ->
    key = randomKey(16)
    try
      string = JSON.stringify(value)
    catch error
      callback error
      return

    multi = @redis.multi()
    multi.zadd @keys.index, Date.now(), key
    multi.hset @keys.storage, key, string
    multi.exec (error, results) =>
      callback null, key
    @redis.zremrangebyrank @keys.index, 0, -@size, (error, result) =>


  fetch: (key, callback) ->
    @redis.hget @keys.storage, key, (error, result) ->
      if error
        callback error
      else
        try
          value = JSON.parse(result)
        catch error
          callback error
          return
        callback null, value
        @redis.zadd @keys.index, Date.now(), key, (error, result) =>


