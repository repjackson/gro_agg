@selected_comment_tags = new ReactiveArray []
@selected_sub_tags = new ReactiveArray []

Router.route '/subs', (->
    @layout 'layout'
    @render 'subs'
    ), name:'subs'


Router.route '/r/:subreddit/users', (->
    @layout 'layout'
    @render 's_users'
    ), name:'s_users'
    
Template.reddit_page.onCreated ->
    @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
Template.reddit_page.onRendered ->
    Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->


Template.rcomments_tab.onCreated ->
    @autorun -> Meteor.subscribe('rpost_comments', Router.current().params.subreddit, Router.current().params.doc_id)
    @autorun -> Meteor.subscribe('rpost_comment_tags', 
        Router.current().params.subreddit
        Router.current().params.doc_id
        selected_comment_tags.array()
    )
Template.rcomment.onRendered ->
    unless @data.watson
        # console.log 'calling watson on comment'
        Meteor.call 'call_watson', @data._id,'data.body','comment',->

Template.rcomments_tab.events
    'click .get_post_comments': ->
        Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->
Template.rcomment.events
    'click .call_watson_comment': ->
        unless @watson
            console.log 'calling watson on comment'
            Meteor.call 'call_watson', @_id,'data.body','comment',->

Template.reddit_page.events
    'click .goto_sub': -> 
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
            Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
            Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
    'click .call_visual': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'url', ->
    'click .call_meta': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'meta', ->
    'click .call_thumbnail': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'thumb', ->
    'click .goto_ruser': ->
        doc = Docs.findOne Router.current().params.doc_id
        Meteor.call 'get_user_info', doc.data.author, ->
    'click .get_post': ->
        Session.set('view_section','main')
        Meteor.call 'get_reddit_post', Router.current().params.doc_id, @reddit_id, ->
Template.call_tone.events
    'click .call': (e,t)->
        console.log 'calling tone'
        Meteor.call 'call_tone', Router.current().params.doc_id,->

Template.rcomments_tab.helpers
    rcomments: ->
        post = Docs.findOne Router.current().params.doc_id
        Docs.find(
            model:'rcomment'
            parent_id:"t3_#{post.reddit_id}"
        ,sort:"data.score":-1)
    rcomment_tags: ->
        results.find(model:'rpost_comment_tag')

    
Template.post_related.onCreated ->
    @autorun -> Meteor.subscribe('related_posts', Router.current().params.doc_id)

Template.post_related.helpers
    related_posts: ->
        post = Docs.findOne Router.current().params.doc_id
        Docs.find(
            model:'rpost'
            tags:$in:post.tags
            _id:$ne:post._id
        , limit:10)


Template.related_questions.onCreated ->
    @autorun -> Meteor.subscribe('related_questions', Router.current().params.doc_id)

Template.related_questions.helpers
    qs: ->
        post = Docs.findOne Router.current().params.doc_id
        Docs.find(
            model:'stack_question'
            tags:$in:post.tags
        , limit:10)





Template.subs.onCreated ->
    Session.setDefault('subreddit_query',null)
    Session.setDefault('sort_key','data.created')
    @autorun -> Meteor.subscribe('subreddits',
        Session.get('subreddit_query')
        picked_tags.array()
        Session.get('sort_subs')
    )
    @autorun -> Meteor.subscribe('sub_count',
        Session.get('subreddit_query')
        picked_tags.array()
        Session.get('sort_subs')
    )
    @autorun => Meteor.subscribe 'subreddit_tags',
        selected_sub_tags.array()
        Session.get('toggle')

Template.subs.events
    'click .goto_sub': (e,t)->
        Meteor.call 'get_sub_latest', @data.display_name, ->
        Meteor.call 'get_sub_info', @data.display_name, ->
        Meteor.call 'calc_sub_tags', @data.display_name, ->
        Session.set('view_section', 'main')
    'click .pull_latest': ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'keyup .search_subreddits': (e,t)->
        val = $('.search_subreddits').val()
        Session.set('subreddit_query', val)
        if e.which is 13 
            Meteor.call 'search_subreddits', val, ->
            $('.search_subreddits').val('')
            selected_sub_tags.push val 
            # Session.set('subreddit_query', null)
    'click .search_subs': ->
        Meteor.call 'search_subreddits', 'news', ->
             
Template.subs.helpers
    subreddit_docs: ->
        Docs.find(
            model:'subreddit'
        , {limit:30,sort:"#{Session.get('sort_key')}":-1})
    subreddit_tags: -> results.find(model:'subreddit_tag')

    selected_sub_tags: -> selected_sub_tags.array()

    sub_count: -> Counts.get('sub_counter')