# Description:
#   Just repeats what you tell him to all
#
# Commands:
#   hubot tell everyone '<query>' - repeats to @all
#   hubot say '<query>' - repeats without @all

module.exports = (robot) ->

  robot.respond /tell everyone '(.+)'/i, (msg) ->
    msg.send "@all #{msg.match[1]}"

  robot.respond /say '(.+)'/i, (msg) ->
    msg.send msg.match[1]
