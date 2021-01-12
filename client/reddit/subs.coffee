@selected_comment_tags = new ReactiveArray []
@selected_subs_tags = new ReactiveArray []
@selected_subreddit_authors = new ReactiveArray []
@selected_subreddit_domain = new ReactiveArray []

Router.route '/subs', (->
    @layout 'layout'
    @render 'subs'
    ), name:'subs'

Router.route '/groups', (->
    @layout 'layout'
    @render 'groups'
    ), name:'groups'




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
    Session.setDefault('subreddit_skip',0)
    Session.setDefault('subs_query',null)
    Session.setDefault('sort_key','data.created')
    @autorun -> Meteor.subscribe('subreddits',
        Session.get('subs_query')
        selected_subs_tags.array()
        Session.get('subreddit_sort')
        Session.get('subreddit_skip')
        Session.get('subreddit_sort_direction')
    )
    @autorun -> Meteor.subscribe('sub_count',
        Session.get('subs_query')
        selected_subs_tags.array()
        Session.get('subreddit_skip')
        Session.get('sort_subs')
    )
    @autorun => Meteor.subscribe 'subs_tags',
        selected_subs_tags.array()
        selected_subreddit_domain.array()
        selected_subreddit_authors.array()
        Session.get('toggle')

Template.subs.events
    'click .skip_right': -> Session.set('subreddit_skip', Session.get('subreddit_skip')+1)
    'click .goto_sub': (e,t)->
        Meteor.call 'get_sub_latest', @data.display_name, ->
        Meteor.call 'get_sub_info', @data.display_name, ->
        Meteor.call 'calc_sub_tags', @data.display_name, ->
        Session.set('view_section', 'main')
  
    'click .pull_latest': ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'keyup .search_subs': (e,t)->
        val = $('.search_subs').val()
        Session.set('subs_query', val)
        if e.which is 13 
            Meteor.call 'search_subs', val, ->
            $('.search_subs').val('')
            selected_subs_tags.push val 
            # Session.set('subs_query', null)
    # 'click .search_subs': ->
    #     Meteor.call 'search_subreddits', 'news', ->
             
Template.subs.helpers
    subreddit_docs: ->
        Docs.find(
            model:'subreddit'
        , {limit:30,sort:"#{Session.get('sort_key')}":-1})
    subs_tags: -> results.find(model:'subs_tag')

    selected_subs_tags: -> selected_subs_tags.array()

    sub_count: -> Counts.get('sub_counter')




Template.subs_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
Template.subs_tag_selector.helpers
    selector_class: ()->
        term = 
            Docs.findOne 
                title:@name.toLowerCase()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then " basic green"
                    when "anger" then " basic red"
                    when "sadness" then " basic blue"
                    when "disgust" then " basic orange"
                    when "fear" then " basic grey"
                    else "basic grey"
    term: ->
        Docs.findOne 
            title:@name.toLowerCase()
            
            
Template.subs_tag_selector.events
    'click .select_subs_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'subreddit_emotion'
        #     selected_emotions.push @name
        # else
        # if @model is 'subreddit_tag'
        selected_subs_tags.push @name
        $('.search_subreddit').val('')
        
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        Session.set('subs_loading',true)
        Meteor.call 'search_subs', @name, ->
            Session.set('subs_loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)
        
        
        

Template.subs_unselect_tag.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
    
Template.subs_unselect_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.subs_unselect_tag.events
    'click .unselect_subs_tag': -> 
        Session.set('skip',0)
        console.log @
        selected_subs_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
    

Template.flat_subs_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
Template.flat_subs_tag_selector.helpers
    selector_class: ()->
        term = 
            Docs.findOne 
                title:@valueOf().toLowerCase()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then " basic green"
                    when "anger" then " basic red"
                    when "sadness" then " basic blue"
                    when "disgust" then " basic orange"
                    when "fear" then " basic grey"
                    else "basic grey"
    term: ->
        Docs.findOne 
            title:@valueOf().toLowerCase()
Template.flat_subs_tag_selector.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        selected_subs_tags.push @valueOf()
        Router.go "/r/#{Router.current().params.subreddit}/"
        $('.search_subreddit').val('')
        Session.set('loading',true)
        Meteor.call 'search_subreddit', Router.current().params.subreddit, @valueOf(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 3000)
