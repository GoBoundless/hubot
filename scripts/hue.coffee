# Description:
#   Control Philips Hue Lights
#
# Dependencies:
#  "node-hue-api": "0.2.x"
#
# Commands:
#   hubot red alert
#

hue        = require "node-hue-api"
color      = require "onecolor"
HueApi     = hue.HueApi
lightState = hue.lightState
host       = process.env.HUBOT_HUE_HOST
username   = process.env.HUBOT_HUE_USERNAME

module.exports = (robot) ->

  robot.respond /red alert/i, (msg) ->
    api = new HueApi(host, username)

    state = lightState.create().on().rgb(255, 0, 0).effect('none')

    api.setGroupLightState(0, state)

    msg.send "Battle stations!"

  robot.respond /all clear/i, (msg) ->
    api = new HueApi(host, username)

    state = lightState.create().on().xy(0.4595, 0.4105).effect('none')

    api.setGroupLightState(0, state)

    msg.send "Stand down"

  robot.respond /reset lights/i, (msg) ->
    api = new HueApi(host, username)

    state = lightState.create().on().xy(0.4595, 0.4105).effect('none')

    api.setGroupLightState(0, state)

    msg.send "Lights reset"

  robot.respond /it's bedtime/i, (msg) ->
    api = new HueApi(host, username)

    state = lightState.create().off()

    api.setGroupLightState(0, state)

    msg.send "Sweet dreams little Boundling ;)"

  robot.respond /celebrate/i, (msg) ->
    api = new HueApi(host, username)

    state = lightState.create().on().hsl(1, 100, 100).effect('colorloop')

    api.setGroupLightState(0, state)

    msg.send "Party Time!"

    setTimeout =>
      state = lightState.create().on().xy(0.4595, 0.4105).effect('none')
      api.setGroupLightState(0, state)
    , 10

  robot.respond /color me (.*})/i, (msg) ->
    api = new HueApi(host, username)

    requested_color = color(msg.match[1]).hsl()

    state = lightState.create().on().hsl(requested_color._hue * 360, requested_color._saturation * 100, requested_color._lightness * 100).effect('node')

    api.setGroupLightState(0, state)

    msg.send "Hot."