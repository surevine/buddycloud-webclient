class UsersController extends Backbone.Controller
  routes :
    "users/:jid" : "show"
    "users/:jid/subscribe" : "subscribe"
    
  subscribe: (jid) ->
    user = Users.findOrCreateByJid(jid)
    user.getChannel().subscribe()
    window.location.hash = "#users/#{user.get('jid')}"
    
  show: (jid) ->
    user = Users.findOrCreateByJid(jid)
    # user.subscribe()
    # user.fetchPosts()
    new UsersShowView { model : user }
    
new UsersController
