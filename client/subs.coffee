@picked_comment_tags = new ReactiveArray []
@picked_sub_tags = new ReactiveArray []

Router.route '/subs', (->
    @layout 'layout'
    @render 'subs'
    ), name:'subs'




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
        picked_sub_tags.array()
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
            picked_sub_tags.push val 
            # Session.set('subreddit_query', null)
    'click .search_subs': ->
        Meteor.call 'search_subreddits', 'news', ->
             
Template.subs.helpers
    subreddit_docs: ->
        Docs.find(
            model:'subreddit'
        , {limit:30,sort:"#{Session.get('sort_key')}":-1})
    subreddit_tags: -> results.find(model:'subreddit_tag')

    picked_sub_tags: -> picked_sub_tags.array()

    sub_count: -> Counts.get('sub_counter')