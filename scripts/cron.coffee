# Description:
#   Run hubot tasks at given times
#
# Commands:
#   None

cronJob = require('cron').CronJob

module.exports = (robot) ->
  standup_reminder = new cronJob("00 30 10 * * 2-5", ->
    robot.messageRoom("26455_boundless@conf.hipchat.com", "@all standup!")
  , null, true, "US/Eastern")

  pull_request_reminder = new cronJob("00 00 16 * * 1-5", ->
    robot.messageRoom("26455_boundless@conf.hipchat.com", "@all it's that time again.. get your pull request on.")
  , null, true, "US/Eastern")

  standup_reminder.start()
  pull_request_reminder.start()