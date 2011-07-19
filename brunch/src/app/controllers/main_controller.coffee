# needed collection
{ UserSubscriptions } = require('collections/user_subscriptions')
# views
{ RegisterView } = require('views/register/show')
{ LoginView } = require('views/login/show')
{ IndexView } = require('views/home/index')
{ HomeView } = require('views/home/channel')
{ Sidebar } = require('views/sidebar/show')

class exports.MainController extends Backbone.Router
  routes : # eg http://localhost:8080/#/index
    ""           :"index"
    "/"          :"index"
    "/index"     :"index"
    "/home"      :"home"
    "/register"  :"register"
    "/login"     :"login"

  initialize: =>
    app.debug "initialize main controller"
    Backbone.history.start()

    app.router = this
    # bootstrapping after login
    app.connection_handler.bind "connected", @bootstrap


  setView: (view) =>
    @current_view?.remove()
    @current_view = view
    @current_view.show?()


  bootstrap: =>
    app.handlers.data_handler.get_user_subscriptions()
    app.collections.user_subscriptions = new UserSubscriptions(app.current_user)
    app.collections.user_subscriptions.fetch()
    app.sidebar = new Sidebar
    @home()

  # routes

  home: =>
    @setView app.views.home = new HomeView

  index: =>
    @setView app.views.home = new IndexView

  login: =>
    @setView app.views.login = new LoginView

  register: =>
    @setView app.views.register = new RegisterView

