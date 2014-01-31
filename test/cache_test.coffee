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

  put = context.test ".put", (context) ->

    context.test "with ttl", (context) ->
      cache.put {key: "smurfs", value: ["hefty", "brainy"], ttl: 2000}, (error) ->

        context.test "Succeeds", ->
          assert.ifError error

  put.on "done", ->

    context.test "get with a miss", (context) ->
      cache.get "this should not exist", (error, value) ->
        context.test "Receives null", ->
          assert.ifError error
          assert.equal value, null

    get = context.test ".get", (context) ->
      cache.get "smurfs", (error, value) ->
        context.test "Receives correct value", ->
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




