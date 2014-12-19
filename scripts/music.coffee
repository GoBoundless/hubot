# Description:
#   Control the shared Spotify server in the office
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_MUSIC_API_KEY
#   MUSIC_ROOM_ID
#   MUSIC_ROOM_PRETTY_NAME
#
# Commands:
#   hubot play <spotify_uri>      - Starts playing the given spotify uri (get by right clicking a song in spotify and clicking "Copy Spotify URI")
#   hubot pause music             - Pauses the music
#   hubot resume music            - Resumes the music
#   hubot next song               - Skips to the next song
#   hubot skip song               - Skips to the next song
#   hubot previous song           - Goes to the previous song
#   hubot shuffle music           - Shuffles the music
#   hubot don't shuffle music     - Stops shuffling the music
#   hubot loop music              - Loops the music
#   hubot don't loop music        - Stops looping the music
#   hubot what's the volume?      - Gets the current volume
#   hubot set volume <0 to 100>   - Sets the volume to the given percentage
#   hubot what's playing?         - Lists what's currently being played
#
# Author:
#   Kevin Mook (@kevinmook)

module.exports = (robot) ->

  robot.respond /\s*play (.*)/i, (msg) ->
    tellSpotify msg, "play", {uri: msg.match[1]}, {}, (response) ->
      tellSpotify msg, "status", {}, {}, (response) ->
        track = response['track']
        artist = response['artist']
        msg.send "Now playing '#{track}' by '#{artist}.'"
  
  robot.respond /\s*(?:pause|stop) (?:the )?music/i, (msg) ->
    tellSpotify msg, "pause", {}, {}, (response) ->
      msg.send "The music has been paused."
  
  robot.respond /\s*(?:unpause|resume) (?:the )?music/i, (msg) ->
    tellSpotify msg, "resume", {}, {}, (response) ->
      msg.send "The music has been resumed."
  
  robot.respond /\s*(?:skip|next) (?:this )?song/i, (msg) ->
    tellSpotify msg, "next", {}, {}, (response) ->
      msg.send "The current song has been skipped."
  
  robot.respond /\s*previous song/i, (msg) ->
    tellSpotify msg, "previous", {}, {}, (response) ->
      msg.send "Going back to the previous song."
  
  robot.respond /\s*shuffle (?:the )?music/i, (msg) ->
    tellSpotify msg, "set_shuffling", {shuffling: true}, {}, (response) ->
      msg.send "The playlist will now be shuffled."
  
  robot.respond /\s*don.?t shuffle (?:the )?music/i, (msg) ->
    tellSpotify msg, "set_shuffling", {shuffling: false}, {}, (response) ->
      msg.send "The playlist will not be shuffled."
  
  robot.respond /\s*loop (?:the )?music/i, (msg) ->
    tellSpotify msg, "set_looping", {looping: true}, {}, (response) ->
      msg.send "The playlist will now be looped."
  
  robot.respond /\s*don.?t loop (?:the )?music/i, (msg) ->
    tellSpotify msg, "set_looping", {looping: false}, {}, (response) ->
      msg.send "The playlist will not be looped."
  
  robot.respond /\s*set (?:the )?volume (?:to )?([0-9]+)/i, (msg) ->
    tellSpotify msg, "set_volume", {volume: msg.match[1]}, {}, (response) ->
      volume = response['volume']
      msg.send "The volume has been set to #{volume}."
  
  robot.respond /\s*what.?s (?:the )?volume\??/i, (msg) ->
    tellSpotify msg, "status", {}, {anywhere: true}, (response) ->
      volume = response['volume']
      msg.send "The volume is at #{volume}."
  
  robot.respond /\s*what.?s (?:playing|the music)\??/i, (msg) ->
    tellSpotify msg, "status", {}, {anywhere: true}, (response) ->
      track = response['track']
      artist = response['artist']
      uri = response['uri']
      url = uri.replace(/:/g, "/").replace("spotify/", "http://open.spotify.com/")
      msg.send "#{url}"
  
  robot.respond /\s*fix (?:the )?music/i, (msg) ->
    tellSpotify msg, "connect", {}, {anywhere: true}, (response) ->
      msg.send "The music should be fixed."
  
  
tellSpotify = (msg, command, params, options, callback) ->
  if (music_room_id = process.env.MUSIC_ROOM_ID) && !options["anywhere"]
    user = msg.message.user
    user_name = user.name
    room = user.flow
    if room != music_room_id
      music_room_pretty = process.env.MUSIC_ROOM_PRETTY_NAME || music_room_id
      msg.send "Music can only be controlled from #{music_room_pretty}."
      return
  
  music_api_key = process.env.HUBOT_MUSIC_API_KEY
  params_str = ""
  
  for key, value of params
    clean_key = escape(key)
    clean_value = escape(value)
    params_str += "&#{clean_key}=#{clean_value}"
  
  url = "http://music.boundlesslearning.com/spotify/#{command}?api_key=#{music_api_key}#{params_str}"
  msg.http(url)
    .get() (err, res, body) ->
      if err
        msg.send "Error communicating with the Spotify client: #{err}"
        return
      content = JSON.parse(body)
      callback(content)
