{ Model } = require './base'
{ NodeStore } = require '../collections/node'
{ gravatar } = require '../util'

class exports.Channel extends Model
    initialize: ->
        @unread_count = 0
        @id = @get 'id' # jid
        @last_touched = new Date
        @nodes = new NodeStore channel:this
        @avatar = gravatar @id
        @nodes.fetch()

        # Auto-create the default set of nodes for that channel, so
        # that its data can be retrieved via XMPP
        ["posts", "status", "subscriptions",
         "geo/previous", "geo/current", "geo/next"].forEach (id) =>
            @nodes.get_or_create {id, nodeid:"/user/#{@id}/#{id}"}
        @nodes.get('posts').on('post:updated', @trigger.bind(this, 'post:updated'))

    push_post: (nodeid, post) ->
        @trigger 'post', nodeid, post

    # subscription.jid is already filtered for this channel id (user)
    push_subscription: (subscription) ->
        # subscription.subscription is either subscribed, none or pending
        @trigger 'subscription', subscription

    push_affiliation: (affiliation) ->
        @trigger 'affiliation', affiliation

    push_metadata: (nodeid, metadata) ->
        @trigger 'metadata', nodeid, metadata

    push_node_error: (nodeid, error) ->
        @trigger 'node:error', nodeid, error

    set_loading: (@isLoading) =>
        if @isLoading
            @trigger 'loading:start'
        else
            @trigger 'loading:stop'

    count_unread: ->
        last_view = @get('last_view') or (new Date 0).toISOString()
        count = 0
        for post in (@nodes.get('posts')?.posts.models or [])
            if post.get_last_update() > last_view
                unless post.get 'unread'
                    post.set(unread:yes)
                    post.trigger 'unread'
                count++
            else break
        @trigger 'update:unread', count if count - @unread_count
        app.favicon(count - @unread_count) # only add new ones
        @unread_count = count
        count

    mark_read: ->
        last_view = @get('last_view') or (new Date 0).toISOString()
        posts = @nodes.get('posts').posts
        last_update = posts.first()?.get_last_update()
        if last_update and last_update > last_view
            for post in (@nodes.get('posts')?.posts.models or [])
                if post.get 'unread'
                    post.set(unread:no)
                    post.trigger 'read'
            last_view = last_update
        @trigger 'update:unread', 0 if @unread_count
        app.favicon(@unread_count * -1) # remove them
        @unread_count = 0
        @save { last_view }

    count_notifications: ->
        if app.users.current.canModerate(this)
            # Count users with pending subscription
            postsnode = @nodes.get_or_create(id: 'posts')
            postsnode.subscribers.reduce (count, subscription) ->
                if subscription.get('subscription') is 'pending'
                    count + 1
                else
                    count
            , 0
        else
            # Isn't owner, no admin notifications
            0