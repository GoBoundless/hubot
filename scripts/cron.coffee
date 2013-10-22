# Description:
#   Run hubot tasks at given times
#
# Dependencies
#   "cron": "1.0.1"
#   "time": "0.9.2"
#
# Commands:
#   None

room     = process.env.HUBOT_HIPCHAT_ROOM
username = process.env.HUBOT_PINGDOM_USERNAME
password = process.env.HUBOT_PINGDOM_PASSWORD
app_key  = process.env.HUBOT_PINGDOM_APP_KEY

cronJob = require('cron').CronJob

module.exports = (robot) ->
  standup_reminder = new cronJob("00 30 10 * * 2-5", ->
    robot.messageRoom(room, "@all standup!")
  , null, true, "US/Eastern")

  pull_request_reminder = new cronJob("00 00 16 * * 1-5", ->
    robot.messageRoom(room, "@all it's that time again.. get your pull request on.")
  , null, true, "US/Eastern")

  uptime_monitor = new cronJob("0 * * * * *", ->
    auth = new Buffer("#{username}:#{password}").toString('base64')
    pingdom_url = "https://api.pingdom.com/api/2.0"
    robot.http("#{pingdom_url}/checks")
      .headers(Authorization: "Basic #{auth}", 'App-Key': app_key)
        .get() (err, res, body) ->
          content = JSON.parse(body)
          for check in content.checks
            if check.name == "WWW"
              previous_status = robot.brain.get('siteStatus')
              if previous_status?
                if previous_status.match(/up/) && check.status.match(/down/)
                  robot.emit('siteDown')
                  robot.messageRoom(room, "@all The site appears to be down.")
                else if previous_status.match(/down/) && check.status.match(/up/)
                  robot.emit('siteUp')
                  robot.messageRoom(room, "@all The site appears to be back up.")
              robot.brain.set('siteStatus', check.status)
  , null, true, "US/Eastern")

  standup_reminder.start()
  pull_request_reminder.start()
  uptime_monitor.start()