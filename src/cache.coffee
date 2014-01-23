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
    "#{@namespace}#{key}"

  put: (args...) ->
    [options, callback] = args
    unless typeof(options) == "object" && typeof(callback) == "function"
      @log.warn "'put' called with unusable arguments: #{JSON.stringify(args)}"
      return

    unless typeof(options.key) == "string" && options.value?
      callback new Error "Must supply key and value properties"
      return

    options.ttl ?= @ttl

    try
      options.value = JSON.stringify(options.value)
    catch error
      callback error
      return

    @redis.set @_namespace(options.key), options.value, (error, result) =>
      if error
        callback error
      else
        @log.debug "Stored - #{options.key}\n#{options.value}"
        if !options.ttl
          callback null
        else
          @redis.pexpire @_namespace(options.key), options.ttl, (error, result) =>
            if error
              callback error
            else
              @log.debug "Set ttl for #{options.key}"
              callback null
      

  get: (key, callback) ->
    if !callback?
      @log.warn "'get' called without a callback"
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

  delete: (key, callback) ->
    if !callback?
      @log.warn "'delete' called without a callback"
    else
      @redis.del @_namespace(key), (error, result) =>
        if error
          callback error
        else
          @log.debug "Removed - #{key}"
          callback null, result

