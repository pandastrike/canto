Testify = require "testify"
assert = require "assert"

Cache = require "../src/cache"

cache = new Cache
  log:
    error: ->
    debug: ->
    warn: ->

  namespace: "test-cache/"
  redis:
    host: "localhost"
    port: 6379
    options: {}

Testify.once "done", -> process.exit()

round_trip = (context, description, value) ->
  context.test description, (context) ->

Testify.test "Cache", (context) ->

  put_with_negative_ttl  = context.test ".put with negative ttl", (context) ->

    cache.put {key: "fruit", value: ["apple", "orange"], ttl: -99}, (error) ->

      context.test "Should fail", ->
        assert.ok error

  put_with_zero_ttl  = context.test ".put with ttl as zero", (context) ->

    cache.put {key: "ants", value: ["black", "fire", "brown"], ttl: 0}, (error) ->

      context.test "Should fail", ->
        assert.ok error

  put = context.test ".put", (context) ->

    context.test "with ttl", (context) ->
      cache.put {key: "smurfs", value: ["hefty", "brainy"], ttl: 2000}, (error) ->

        context.test "Succeeds", ->
          assert.ifError error

  put.on "done", ->

    get = context.test ".get", (context) ->
      cache.get "smurfs", (error, value) ->
        context.test "Received correct value", ->
          assert.ifError error
          assert.deepEqual value, ["hefty", "brainy"]

    get.on "done", ->
      context.test ".delete", (context) ->
        cache.delete "smurfs", (error, value) ->
          context.fail(error) if error

          cache.get "smurfs", (error, value) ->
            context.fail(error) if error
            context.test "deletes the item", ->
              assert.equal value, null

    context.test "JSON round trip", (context) ->
      value = {foo: "bar"}
      cache.put {key: "thing", value, ttl: 400}, (error) ->
        context.fail(error) if error
        cache.get "thing", (error, result) ->
          context.test "correct value returned", ->
            assert.deepEqual result, value




