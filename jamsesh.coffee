Rooms = new Meteor.Collection("rooms")

Meteor.methods
  find_or_create_room: (name) ->
    Rooms.insert(name: name, songs: []) unless Rooms.findOne(name: name)
    return Rooms.findOne(name: name)

if Meteor.isClient
  show_room = ->
    Meteor.call "find_or_create_room", @params.room_name, (err, room) =>
      if room?
        songs = room.songs
        Session.setDefault "now_playing", songs[0]
        Session.set "songs", songs
        Session.set "id", room._id

  Meteor.pages
    '/'           : {to: 'homepage', as: 'root'}
    '/:room_name' : {to: 'room', as: 'room', before: show_room}

  Template.room.helpers
    songs: -> Session.get('songs')
    now_playing: -> Session.get('now_playing')

  Template.room.events
    'submit': ->
      song = $("#input").val()
      return false if not song.trim().length
      $("#input").val ''
      url = "http://gdata.youtube.com/feeds/api/videos?q=#{encodeURIComponent(song)}&format=5&max-results=1&v=2&alt=jsonc"

      Rooms.update Session.get("id"), {$push: {songs: song}}
      return false
