
class exports.Connector extends Backbone.EventHandler

    constructor: (@handler, @connection) ->
        @handler.bind 'connecting', => @trigger 'connection:start'
        @handler.bind 'connected',  => @trigger 'connection:established'

    start_fetch_node_posts: (nodeid) =>
        success = (posts) =>
            for post in posts
                @trigger "post", post, nodeid
        error = =>
            app.error "fetch_node_posts", nodeid, arguments
        @connection.buddycloud.getChannelPostStream nodeid, success, error

    get_node_posts: (nodeid, callback) =>
        success = (posts) =>
            for post in posts
                @trigger "post", post, nodeid
            callback? posts
        error = =>
            app.error "get_node_posts", nodeid, arguments
        @connection.buddycloud.getChannelPosts nodeid, success, error

    get_node_metadata: (nodeid, callback) =>
        success = (metadata) =>
            @trigger "metadata:#{nodeid}", metadata
            callback? metadata
        error = =>
            app.error "get_node_metadata", nodeid, arguments
        @connection.buddycloud.getMetadata nodeid, success, error

    # this fetches all user channels
    get_user_subscriptions: =>
        success = (subscriptions) =>
            for subscription in subscriptions
                @trigger 'subscription:user', subscription
        error = =>
            app.error "get_user_subscriptions", arguments
        @connection.buddycloud.getUserSubscriptions success, error

    # this fetches all subscriptions to a specific node
    get_node_subscriptions: (nodeid) ->
        # TODO
        # @trigger 'subscription:node', subscription

