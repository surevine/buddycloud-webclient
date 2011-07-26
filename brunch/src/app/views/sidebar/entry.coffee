
class exports.ChannelEntry extends Backbone.View
    template: require 'templates/sidebar/entry'

    initialize: ->
        @el = $("<div>").attr id:@cid
        @model.bind 'change:node:metadata', @render

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        @el.click =>
            app.views.home.setCurrentChannel @model.cid
            app.views.home.sidebar.current?.render()
            app.views.home.sidebar.current = this
            @render()

    isPersonal : (a, b) =>
        (@channel?.metadata?.owner?.value is app.users.current.get('jid')) and (a ? true) or (b ? false)

    isSelected : (a, b) =>
        (app.views.home?.current?.model.cid is @model.cid) and (a ? true) or (b ? false)

    update_attributes: ->
        if (channel = @model.nodes.get 'channel')
            @channel = channel.toJSON yes
        if (mood = @model.nodes.get 'mood')
            @mood = mood.toJSON yes
        if (geo = @model.nodes.get 'geo')
            @geo = geo.toJSON yes
