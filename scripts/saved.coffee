# Description:
#   Save links to saved.io
#
# Dependencies:
#   request
#
# Configuration:
#   None
#
# Commands:
#   hubot link of the day <link> -- <description>    - sends a link to saved.io
#
# Author:
#   Joe Webb (@MeanwhileMedia)

request = require 'request'

module.exports = (robot) ->

  robot.respond /(link of the day )(.*)( -- )(.*)/i, (msg) ->
    savedIo msg, msg.match[2], msg.match[4], (success, response) ->
      if !success
        msg.send "I couldn't save that link: #{response}"
      else
        msg.send "Link of the day saved. It will be published to Boundless.codes first thing tomorrow."


savedIo = (msg, link, description, callback) ->
  if link.indexOf('http://') == -1
    link = 'http://'+link

  postData = {
    token: '7674efe121b69608e92565cbe1241565',
    url: link,
    title: description
  }
  request.post("http://devapi.saved.io/v1/create", {form:postData}, (err, httpResponse, body) ->
    body = JSON.parse(body)
    if err
      callback(false, err)
    else if body.is_error
      callback(false, body.message)
    else
      callback(true)
  )
