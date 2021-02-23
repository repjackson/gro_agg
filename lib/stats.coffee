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
        @autorun => Meteor.subscribe 'post_count'
        @autorun => Meteor.subscribe 'global_stats'
        
        
    Template.nav.helpers
        global_karma: ->
            gs = 
                Docs.findOne 
                    model:'global_stats'
            if gs
                gs.global_karma
    Template.stats.helpers
        global_karma: ->
            gs = 
                Docs.findOne 
                    model:'global_stats'
            if gs
                gs.global_karma
        user_count: -> Counts.get 'user_count'
        reflection_count: -> Counts.get 'reflection_count'
        comment_count: -> Counts.get 'comment_count'
        definition_count: -> Counts.get 'definition_count'
        tip_count: -> Counts.get 'tip_count'
        post_count: -> Counts.get 'post_count'
    

Meteor.methods
    add_global_karma: ->
        gs = 
            Docs.findOne 
                model:'global_stats'
        # console.log gs
        if gs
            Docs.update gs._id,
                $inc:global_karma:1
        else
            Docs.insert
                model:'global_stats'
if Meteor.isServer
    Meteor.publish 'global_stats', ()->
        Docs.find
            model:'global_stats'
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
    
    Meteor.publish 'post_count', (
        # picked_tags
        # toggle
        )->
        match = {
            model:'post'
        }
    
        # match.tags = $all:picked_tags
        # if picked_tags.length
        Counts.publish this, 'post_count', Docs.find(match)
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
    