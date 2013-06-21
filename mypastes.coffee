Boards = new Meteor.Collection("pastes")

Meteor.methods
  ensure_exists: (username) ->
    unless Boards.findOne(username: username)
      Boards.insert(username: username, pastes: [])

if Meteor.isClient
  show_board = ->
    Meteor.call "ensure_exists", @params.username
    board = Boards.findOne(username: @params.username)
    @set "pastes", board?.pastes.reverse() or []
    Session.set "username", @params.username
    Session.set "id", board._id

  Meteor.pages
    '/'          : {to: 'homepage', as: 'root'}
    '/:username' : {to: 'mypastes', as: 'pastes', before: show_board}

  Template.mypastes.helpers
    parse: (paste) ->
      if paste.split(' ').length > 1 or /\<|\>|'|"/.test(paste)
        return paste
      if /^http/.test paste
        return new Handlebars.SafeString("<a href='#{paste}'>#{paste}</a>")
      return paste

  Template.mypastes.events
    'keydown #input': (e) ->
      # 86 is 'v'
      if (e.ctrlKey or e.metaKey) and (e.keyCode == 86)
        setTimeout (-> document.getElementById('submit').click()), 10
    'submit': ->
      paste = $("#input").val()
      return false if not paste.trim().length
      $("#input").val ''

      username = Session.get "username"
      Boards.update Session.get("id"), {$push: {pastes: paste}}
      return false
