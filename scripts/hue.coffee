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
HueApi     = hue.HueApi
lightState = hue.lightState
host       = process.env.HUBOT_HUE_HOST
username   = process.env.HUBOT_HUE_USERNAME

module.exports = (robot) ->

  robot.respond /red alert/i, (msg) ->
    api = new HueApi(host, username)

    state = lightState.create().on().rgb(255,0,0).effect('none')

    api.setGroupLightState(0, state)

    msg.send "Battle stations!"

  robot.respond /all clear/i, (msg) ->
    api = new HueApi(host, username)

    state = lightState.create().on().xy(0.4595, 0.4105).effect('none')

    api.setGroupLightState(0, state)

    msg.send "Stand down"

  robot.respond /celebrate/i, (msg) ->
    api = new HueApi(host, username)

    state = lightState.create().on().hsl(1, 254, 254).effect('colorloop')

    api.setGroupLightState(0, state)

    msg.send "Party Time!"

    setTimeout =>
      state = lightState.create().on().xy(0.4595, 0.4105).effect('none')
      api.setGroupLightState(0, state)
    , 10