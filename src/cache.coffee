redis = require "redis"
log4js = require "log4js"
{randomKey} = require "key-forge"

module.exports = class Cache

  constructor: (@configuration) ->
    {@log, @namespace, @ttl, redis: {host, port, options}} = @configuration

    @log ?= log4js.getLogger("Cache")
    @namespace ?= "cache"
    @ttl ?= false

    @redis = redis.createClient port, host, options
    @redis.on "error", (error) =>
      @log.error "Problem with Redis: #{error}"

  _namespace: (key) ->
    "#{@namespace}/#{key}"

  store: (args...) ->
    # TODO:  Typely
    unless args.length == 2 && typeof(args[1]) == "function"
      @log.warn "'store' called with unusable arguments: #{JSON.stringify(args)}"
      return

    callback = args[1]
    if typeof(args[0]) == "string"
      options = {value: args[0], ttl: @ttl}
    else if args[0].value?
      options = args[0]
      options.ttl ?= @ttl
    else
      callback new Error "Must supply value property"
      return

    try
      options.value = JSON.stringify(options.value)
    catch error
      callback error
      return

    key = randomKey(16)
    @redis.set @_namespace(key), options.value, (error, result) =>
      if error
        callback error
      else
        @log.debug "Stored - #{key}\n#{options.value}"
        if !options.ttl
          callback null, key
        else
          @redis.pexpire @_namespace(key), options.ttl, (error, result) =>
            if error
              callback error
            else
              @log.debug "Set ttl for #{key}"
              callback null, key
      
  fetch: (key, callback) ->
    if !callback?
      @log.warn "'fetch' called without a callback"
    else
      @redis.get @_namespace(key), (error, result) =>
        if error
          callback error
        else
          @log.debug "Fetched - #{key}\n#{result}"
          try
            callback null, JSON.parse(result)
          catch error
            callback error

  remove: (key, callback) ->
    if !callback?
      @log.warn "'remove' called without a callback"
    else
      @redis.del @_namespace(key), (error, result) =>
        if error
          callback error
        else
          @log.debug "Removed - #{key}"
          callback null, result

