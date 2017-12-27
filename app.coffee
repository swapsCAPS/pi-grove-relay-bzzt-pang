async = require "async"
gpio = require "rpi-gpio"
request = require "request"

secret = require "./secret"

closePins = (cb) ->
	gpio.destroy ->
		console.log "destroyed"
		cb()

closePins ->
	gpio.setup 7, gpio.DIR_OUT, ->
		process.on "SIGTERM", ->
			console.log "termed"
			closePins ->
				process.exit 0

		process.on "SIGINT", ->
			console.log "int"
			closePins ->
				process.exit 0

		getSome()


getSome = (cb) ->
	request.get "http://#{secret.server}:#{secret.port}/mariStatus/#{secret.one}/#{secret.two}", json: true, (error, res) ->
		if error
			console.log error
			console.log "retrying in 5s"
			return setTimeout getSome, 5000
		console.log "res", res.body

		goOn = res.body.status

		gpio.write 7, goOn, (error) ->
			throw error if error
			console.log "written"
			setTimeout getSome, 1000
