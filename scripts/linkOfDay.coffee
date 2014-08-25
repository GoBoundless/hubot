# Description:
#   Save links to saved.io, then publish them to squarespace once a day for a "Links of the day" post
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
qs = require 'querystring'

savedIoToken = '7674efe121b69608e92565cbe1241565'
mandrillToken = 'hQ9kLzEyVGfLVc3lhQfWWA'
ssPublishEmail = 'pbm+boundless-learning+ejx0g8@squarespace.com'

module.exports = (robot) ->

  robot.respond /link of the day (.*) (?:--|—) (.*)/i, (msg) ->
    lod.savedIoPost msg, msg.match[2], msg.match[4], (success, response) ->
      if !success
        msg.send "I couldn't save that link: #{response}"
      else
        msg.send "Link of the day saved. It will be published to Boundless.codes first thing tomorrow."


class linkOfDay

  constructor: () ->
    @initLinkCheckInterval()

  savedIoPost: (msg, link, description, callback) ->
    if link.indexOf('http://') == -1 && link.indexOf('https://') == -1
      link = 'http://'+link

    postData = {
      token: '7674efe121b69608e92565cbe1241565',
      url: link,
      title: description
    }
    request.post "http://devapi.saved.io/v1/create", {form:postData}, (err, httpResponse, body) =>
      body = JSON.parse(body)
      if err
        callback(false, err)
      else if body.is_error
        callback(false, body.message)
      else
        callback(true)


  #Check for new links right here on our hubot server. When found, publish to squarespace via email
  initLinkCheckInterval: ->
    setInterval () =>
      @checkForNew()
    , 3600000 #every hour


  checkForNew: ->
    yday = new Date()
    yday.setDate(yday.getDate()) #-1
    ydayStart = new Date(yday.getFullYear(), yday.getMonth(), yday.getDate()).getTime()
    ydayEnd = ydayStart + 86400000 #+ 1 day (ms)

    getData = {
      token: savedIoToken,
      from: ydayStart/1000, #seconds
      to: ydayEnd/1000
    }
    request.get "http://devapi.saved.io/v1/bookmarks?"+qs.stringify(getData), (err, httpResponse, body) =>
      linkArr = JSON.parse body
      if linkArr instanceof Array && linkArr.length > 0
        #Post new links to a new Links of the day post, then delete them from
        #saved.io so we don't publish duplicates.
        for key, val of linkArr
          @deleteLink(val)
        @createPost(linkArr)


  deleteLink: (link) ->
    postData = {
      token: savedIoToken,
      bk_id: link.bk_id
    }
    request.post "http://devapi.saved.io/v1/delete", {form:postData}


  createPost: (linkArr) ->
    #when we post via email, squarespace doesn't allow us to send html. Instead, let's send
    #a json string, making that the post body, then our js will apply the proper html on page load.
    postData = {
      'key': mandrillToken,
      'message': {
        'from_email': 'jwebb@boundless.com',
        'to': [
          {
            'email': ssPublishEmail,
            'type': 'to'
          }
        ],
        'subject': 'Links of the day',
        'text': "<div class='linksJson'>"+JSON.stringify(linkArr)+"</div>"
      }
    }
    request.post "https://mandrillapp.com/api/1.0/messages/send.json", {form:postData}


#####
#Start it up
lod = new linkOfDay
