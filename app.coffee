async = require "async"
gpio = require "rpi-gpio"

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

		gpio.write 7, true, (error) ->
			throw error if error
			console.log "written"
