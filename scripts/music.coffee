# Description:
#   Control the shared Spotify server in the office
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot play <spotify_uri>      - Starts playing the given spotify uri
#   hubot pause music             - Pauses the music
#   hubot resume music            - Resumes the music
#   hubot next song               - Skips to the next song
#   hubot skip song               - Skips to the next song
#   hubot previous song           - Goes to the previous song
#   hubot set volume <0 to 100>   - Sets the volume to the given percentage
#   hubot what's playing?         - Lists what's currently being played
#
# Author:
#   Kevin Mook (@kevinmook)

module.exports = (robot) ->

  robot.respond /play (.*)/i, (msg) ->
    tellSpotify msg, "play", {uri: msg.match[1]}, (response) ->
      tellSpotify msg, "status", {}, (response) ->
        track = response['track']
        artist = response['artist']
        msg.send "Now playing '#{track}' by '#{artist}.'"
  
  robot.respond /pause (?:the )?music/i, (msg) ->
    tellSpotify msg, "pause", {}, (response) ->
      msg.send "The music has been paused."
  
  robot.respond /resume (?:the )?music/i, (msg) ->
    tellSpotify msg, "resume", {}, (response) ->
      msg.send "The music has been resumed."
  
  robot.respond /(?:skip|next) (?:this )?song/i, (msg) ->
    tellSpotify msg, "next", {}, (response) ->
      msg.send "The current song has been skipped."
  
  robot.respond /previous song/i, (msg) ->
    tellSpotify msg, "previous", {}, (response) ->
      msg.send "Going back to the previous song."
  
  robot.respond /set (?:the )?volume (?:to )?([0-9]+)/i, (msg) ->
    tellSpotify msg, "set_volume", {volume: msg.match[1]}, (response) ->
      volume = response['volume']
      msg.send "The volume has been set to #{volume}."
  
  robot.respond /what'?s (?:playing|the music)\?/i, (msg) ->
    tellSpotify msg, "status", {}, (response) ->
      track = response['track']
      artist = response['artist']
      uri = response['uri']
      msg.send "Currently '#{track}' by '#{artist}' (#{uri}) is playing."
  
  
tellSpotify = (msg, command, params, callback) ->
  api_key = "oAj7hCqVJdRfYTfmXePE7CnnWUPWeN"
  params_str = ""
  
  for key, value of params
    clean_key = escape(key)
    clean_value = escape(value)
    params_str += "&#{clean_key}=#{clean_value}"
  
  url = "http://music.boundlesslearning.com/spotify/#{command}?api_key=#{api_key}#{params_str}"
  msg.http(url)
    .get() (err, res, body) ->
      if err
        msg.send "Error communicating with the Spotify client: #{err}"
        return
      content = JSON.parse(body)
      callback(content)
