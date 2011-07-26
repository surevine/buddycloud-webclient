
# The channel shows channel content
class exports.ChannelView extends Backbone.View
    template: require 'templates/channel/show'

    initialize: ->
        @el = $("<div>").attr id:@cid
        @model.bind 'change:node:metadata', @render

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        @info = @el.find('.channelDetails')
        #@el.find('.info.button').click => @info.toggleClass('hidden')

    update_attributes: ->
        if (channel = @model.nodes.get 'channel')
            @channel = channel.toJSON yes
        if (mood = @model.nodes.get 'mood')
            @mood = mood.toJSON yes
        if (geo = @model.nodes.get 'geo')
            @geo = geo.toJSON yes
#         @user =
#             notFollowingThisChannel: @channel.sink isnt app.current_user.get('jid')
#             hasRightToPost: @channel.affiliation in ["owner", "publisher"] #permissions
