if Meteor.isClient
    selected_ruser_post_tags = new ReactiveArray()
    selected_ruser_post_time_tags = new ReactiveArray()
    Router.route '/ruser/:username', (->
        @layout 'layout'
        @render 'ruser'
        ), name:'ruser'

   
    Template.ruser.onCreated ->
        Session.setDefault('session_ruser_post_skip',0)
        @autorun => Meteor.subscribe 'ruser_doc', Router.current().params.username
        @autorun => Meteor.subscribe 'rposts', 
            Router.current().params.username, 
            selected_ruser_post_tags.array()
            selected_ruser_post_time_tags.array()
            Session.get('rpost_skip_right')
        @autorun => Meteor.subscribe 'ruser_related', Router.current().params.username
        @autorun => Meteor.subscribe 'ruser_comments', Router.current().params.username
        @autorun => Meteor.subscribe 'ruser_result_tags',
            'rpost'
            Router.current().params.username
            selected_ruser_post_tags.array()
            selected_ruser_post_time_tags.array()
            # selected_subreddit_domain.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'ruser_result_tags',
            'rcomment'
            Router.current().params.username
            selected_ruser_post_tags.array()
            selected_ruser_post_time_tags.array()
            # selected_subreddit_domain.array()
            Session.get('toggle')

    Template.ruser.onRendered ->
        selected_ruser_post_tags.clear()
        selected_ruser_post_time_tags.clear()
        Meteor.call 'get_user_comments', Router.current().params.username, ->
        Meteor.setTimeout =>
            Meteor.call 'get_user_info', Router.current().params.username, ->
                Meteor.call 'get_user_posts', Router.current().params.username, ->
                    Meteor.call 'ruser_omega', Router.current().params.username, ->
                        Meteor.call 'rank_ruser', Router.current().params.username, ->
        , 2000

    Template.ruser_doc_item.onRendered ->
        # console.log @
        unless @data.watson
            Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
 
    Template.ruser_comment.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->
        unless @data.time_tags
            # console.log 'calling watson on comment'
            Meteor.call 'tagify_time_rpost', @data._id,->
    Template.ruser_post.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->
        unless @data.time_tags
            # console.log 'calling watson on comment'
            Meteor.call 'tagify_time_rpost', @data._id,->

    Template.ruser.helpers
        selected_ruser_post_tags: -> selected_ruser_post_tags.array()
        selected_ruser_post_time_tags: -> selected_ruser_post_time_tags.array()
        ruser_post_tag_results: -> results.find(model:'rpost_result_tag')
        ruser_comment_tag_results: -> results.find(model:'rcomment_result_tag')
        ruser_rposts: ->
            Docs.find(
                model:'rpost'
                # user_id:parseInt(Router.current().params.username)
                # subreddit:Router.current().params.subreddit
            ,
                sort:"data.ups":-1
                limit:10
                skip:Session.get('session_ruser_post_skip')
            )

        related_users: ->
            current_ruser = Docs.findOne({model:'ruser',username:Router.current().params.username})
            Docs.find({_id:$in:current_ruser.related_ruser_ids}).fetch()
    Template.ruser.events
        'click .select_ruser_post_tag': -> selected_ruser_post_tags.push @name
        'click .unselect_ruser_post_tag': -> selected_ruser_post_tags.remove @valueOf()
    
        'click .select_ruser_post_time_tag': -> selected_ruser_post_time_tags.push @name
        'click .unselect_ruser_post_time_tag': -> selected_ruser_post_time_tags.remove @valueOf()
    
        'click .get_user_info': ->
            Meteor.call 'get_user_info', Router.current().params.username, ->
        'click .search_tag': -> 
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            selected_ruser_tags.clear()
            selected_ruser_tags.push @valueOf()
            Router.go "/rusers"

        'click .call_related': ->
            Meteor.call 'call_ruser_related', Router.current().params.username, ->

        'click .get_user_posts': ->
            Meteor.call 'get_user_posts', Router.current().params.username, ->
            Meteor.call 'ruser_omega', Router.current().params.username, ->
            Meteor.call 'rank_ruser', Router.current().params.username, ->

        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .toggle_question_detail': (e,t)-> Session.set('view_question_detail',!Session.get('view_question_detail'))
        'click .rpost_skip_left': (e,t)-> Session.set('rpost_skip_right',Session.get('view_question_detail')-1)
        'click .rpost_skip_right': (e,t)-> Session.set('rpost_skip_right',Session.get('view_question_detail')+1)

        'click .search': ->
            window.speechSynthesis.speak new SpeechSynthesisUtterance "import #{Router.current().params.username}"
            Meteor.call 'search_ruser', Router.current().params.username, ->
        

    
if Meteor.isServer
    Meteor.methods
        call_ruser_related: (username)->
            ruser = 
                Docs.findOne 
                    model:'ruser'
                    username:username
            # console.log ruser
            cur = Docs.find({
                model:'ruser'
                tags:$in:ruser.tags
            },
                limit:10
                fields:
                    _id:1
            )
            related_ruser_ids = cur.fetch()
            values = _.values(related_ruser_ids)
            console.log values
            flat = []
            for value in values
                flat.push value._id
            console.log flat
            Docs.update ruser._id,
                $set:
                    related_ruser_ids:flat
            
            
    Meteor.publish 'ruser_doc', (username)->
        Docs.find 
            model:'ruser'
            username:username
    
    Meteor.publish 'rposts', (
        username, 
        selected_ruser_post_tags
        selected_ruser_post_time_tags
        skip
        )->

        match = {
            model:'rpost'
            author:username
        }
        
        if selected_ruser_post_tags.length > 0 then match.tags = $all:selected_ruser_post_tags
        if selected_ruser_post_time_tags.length > 0 then match.time_tags = $all:selected_ruser_post_time_tags
            
            
        Docs.find match,{
            limit:10
            skip:parseInt(skip)
            sort:
                "data.ups":-1
        }  
        
        
    Meteor.publish 'ruser_related', (username)->
        current_ruser = Docs.findOne({model:'ruser',username:username})
        Docs.find({_id:$in:current_ruser.related_ruser_ids})

    
    Meteor.publish 'ruser_comments', (username, limit=20)->
        Docs.find
            model:'rcomment'
            author:username
        , limit:limit