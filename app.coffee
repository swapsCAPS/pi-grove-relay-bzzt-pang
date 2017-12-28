async = require "async"
gpio = require "rpi-gpio"
request = require "request"
player = require("play-sound")()

secret    = require "./secret"
isPlaying = false
audio     = []

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
		if goOn
			unless isPlaying
				isPlaying = true
				play()

		else
			isPlaying = false
			kill()

		gpio.write 7, goOn, (error) ->
			throw error if error
			setTimeout getSome, 1000

kill = () ->
	audio.map (a) ->
		console.log "killing", a
		a.kill "SIGKILL"
		process.kill a.pid, "SIGKILL"
	audio = []

play = (cb) ->
	audio.push player.play "meenjeniet.mp3", omxplayer: [ "-o", "local" ], timeout: 0, (error) ->
		throw error if error and not error.killed
		play() if isPlaying
