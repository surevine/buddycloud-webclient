{ ChannelOverView } = require 'views/sidebar/more'
{ ChannelEntry } = require 'views/sidebar/entry'

# The sidebar shows all channels the user subscribed to
class exports.Sidebar extends Backbone.View
    template: require 'templates/sidebar/show'

    initialize: ({@parent}) ->
        # default's not visible due to nice animation
        $('body').append @template()
        @el = $('#channels > .scrollArea')
        @hidden = yes
        # sidebar entries
        @current = undefined
        @channels = {} # this contains the channel entry views
        new_channel_entry = (channel) =>
            entry = @channels[channel.cid]
            unless entry
                entry = new ChannelEntry model:channel, parent:this
                @channels[channel.cid] = entry
                @current ?= entry
                @el.append entry.el
            entry.render()
        app.users.current.channels.forEach        new_channel_entry
        app.users.current.channels.bind 'change', new_channel_entry
        app.users.current.channels.bind 'add', (channel) =>
            entry = new ChannelEntry model:channel, parent:this
            @channels[channel.cid] = entry
            @current ?= entry
            @el.append entry.el
            entry.render()
        app.users.current.channels.bind 'all', =>
            app.debug "sidebar CHEV-ALL", arguments

        unless app.views.overview?
            app.views.overview = new ChannelOverView
        @overview = app.views.overview

    # sliding in animation
    moveIn: (t = 200) ->
        @el.animate(left:"0px", t)
        @overview.show(t)
        @hidden = no

    # sliding out animation
    moveOut: (t = 200) ->
        @el.animate(left:"-#{@el.width()}px", t)
        @overview.hide(t)
        @hidden = yes