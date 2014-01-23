Testify = require "testify"
assert = require "assert"

Cache = require "../src/cache"

cache = new Cache
  log:
    error: ->
    debug: ->
    warn: ->

  namespace: "test-cache"
  redis:
    host: "localhost"
    port: 6379
    options: {}

Testify.once "done", -> process.exit()

round_trip = (context, description, value) ->
  context.test description, (context) ->

Testify.test "Cache", (context) ->

  store = context.test ".store", (context) ->
    keys = []
    context.result(keys)

    context.test "value, callback", (context) ->
      cache.store "MONKEYS", (error, key) ->

        context.test "Received key", ->
          assert.ifError error
          assert.ok key
          keys[0] = key

    context.test "{value, ttl}, callback", (context) ->
      cache.store {value: "SMURFS", ttl: 200}, (error, key) ->

        context.test "Received key", ->
          assert.ifError error
          assert.ok key
          keys[1] = key


  store.on "done", (keys) ->

    fetch = context.test ".fetch", (context) ->
      cache.fetch keys[0], (error, value) ->
        context.test "Received correct value", ->
          assert.ifError error
          assert.equal value, "MONKEYS"

    fetch.on "done", ->
      remove = context.test ".remove", (context) ->
        cache.remove keys[0], (error, value) ->
          context.fail(error) if error

          cache.fetch keys[0], (error, value) ->
            context.fail(error) if error
            context.test "deletes the item", ->
              assert.equal value, null

  context.test "JSON round trip", (context) ->
    value = {foo: "bar"}
    cache.store {value, ttl: 400}, (error, key) ->
      context.fail(error) if error
      cache.fetch key, (error, result) ->
        context.test "correct value returned", ->
          assert.deepEqual result, value




