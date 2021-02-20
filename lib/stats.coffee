if Meteor.isClient
    Router.route '/stats', (->
        @layout 'layout'
        @render 'stats'
        ), name:'stats'
    
    
    Template.stats.onCreated ->
        @autorun => Meteor.subscribe 'reflection_count'
        @autorun => Meteor.subscribe 'user_count'
        @autorun => Meteor.subscribe 'comment_count'
        @autorun => Meteor.subscribe 'tip_count'
        
        
    Template.stats.helpers
        user_count: -> Counts.get 'user_count'
        reflection_count: -> Counts.get 'reflection_count'
        comment_count: -> Counts.get 'comment_count'
        definition_count: -> Counts.get 'definition_count'
        tip_count: -> Counts.get 'tip_count'
    

if Meteor.isServer
    Meteor.publish 'reflection_count', (
        # picked_tags
        # toggle
        )->
        match = {
            model:'reflection'
        }
    
        # match.tags = $all:picked_tags
        # if picked_tags.length
        Counts.publish this, 'reflection_count', Docs.find(match)
        return undefined
    
    Meteor.publish 'comment_count', (
        # picked_tags
        # toggle
        )->
        match = {
            model:'comment'
        }
    
        # match.tags = $all:picked_tags
        # if picked_tags.length
        Counts.publish this, 'comment_count', Docs.find(match)
        return undefined
    
    
    Meteor.publish 'tip_count', (
        # picked_tags
        # toggle
        )->
        match = {
            model:'tip'
        }
    
        # match.tags = $all:picked_tags
        # if picked_tags.length
        Counts.publish this, 'tip_count', Docs.find(match)
        return undefined
    
    
    Meteor.publish 'user_count', (
        # picked_tags
        # toggle
        )->
        match = {
            # model:'rpost'
        }
    
        # match.tags = $all:picked_tags
        Counts.publish this, 'user_count', Meteor.users.find(match)
        return undefined
    