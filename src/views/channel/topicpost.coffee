{ parallel } = require 'async'
{ CommentsView } = require './comments'
{ PostView } = require './post'
{ BaseView } = require '../base'

class exports.TopicPostView extends BaseView
    template: require '../../templates/channel/topicpost'

    initialize: ->
        @hidden = no
        super
#         @model.bind 'change', @render FIXME
        @model.bind 'change:author', @on_author

        @opener   = new PostView
            type:'opener'
            model:@model
            parent:this

        @comments = new CommentsView
            model:@model.comments
            parent:this

    on_author: =>
        if @model.get('author')?.jid?
            # Show only openers with content
            @hidden = no
            @el?.show()
        else
            # Do not yet show openers that were automatically created
            # for an early-received comment
            @hidden = yes
            @el?.hide()

    render: (callback) ->
        @rendering = yes
        if @model.get('content')?.value?.indexOf?("Waiting for the ") is 0
            console.error "##############", @cid, this
        super ->
            @rendering = no
            parallel [((n)->n())
            ,(_..., next) =>
                @opener.render(next)
            ,(_..., next) =>
                @comments.render(next)
            ],(err) =>
                callback?.call(this)

            if @hidden
                @el?.hide()
            else
                @el?.show()

