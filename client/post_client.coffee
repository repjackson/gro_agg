Template.post.onCreated ->
    @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
    # @autorun -> Meteor.subscribe('rpost_comments', Router.current().params.group, Router.current().params.doc_id)
    Session.set('view_section','comments')
    
Template.post.events ->
    'click .get_post': ->
        Meteor.call 'get_reddit_post', Router.current().params.doc_id, ->
    # Meteor.call 'call_watson',Router.current().params.doc_id,'url','url',=>
    # doc = Docs.findOne Router.current().params.doc_id
    # if doc
    #     Meteor.call 'get_user_info', doc.data.author, ->

Template.post.helpers
    rpost_comments: ->
        post = Docs.findOne Router.current().params.doc_id
        Docs.find
            model:'rcomment'
            parent_id:"t3_#{post.reddit_id}"

Template.rcomments_tab.helpers
    rpost_comments: ->
        post = Docs.findOne Router.current().params.doc_id
        Docs.find {
            model:'rcomment'
            parent_id:"t3_#{post.reddit_id}"
        }, 
            sort: 'data.score':-1
Template.post.events
    'click .get_comments': ->
        $('body').toast(
            position: 'bottom center',
            showIcon: 'alert'
            message: 'getting comments'
            displayTime: 'auto',
            classProgress: 'blue'
        )
        Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, (err,res)->
            if err
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'alert'
                    class: 'error'
                    message: 'error getting comments', err
                    displayTime: 'auto',
                    classProgress: 'purple'
                )
            else
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'checkmark'
                    class: 'success'
                    message: 'got comments', err
                    displayTime: 'auto',
                    classProgress: 'blue'
                )

    'click .read': (e,t)-> 
        if @tone 
            window.speechSynthesis.cancel()
            for sentence in @tone.result.sentences_tone
                # console.log sentence
                Session.set('current_reading_sentence',sentence)
                window.speechSynthesis.speak new SpeechSynthesisUtterance sentence.text

    'keyup .tag_post': (e,t)->
        # console.log 
        if e.which is 13
            # $(e.currentTarget).closest('.button')
            tag = $(e.currentTarget).closest('.tag_post').val().toLowerCase().trim()
            # console.log tag
            # console.log @
            Docs.update @_id,
                $addToSet: tags: tag
            $(e.currentTarget).closest('.tag_post').val('')
            # console.log tag

        # $('body').toast(
        position: 'bottom center',
        #     showIcon: 'reddit'
        #     message: 'reddit started'
        #     displayTime: 'auto',
        # )
        # Meteor.call 'search_reddit', selected_tags.array(), ->
        #     $('body').toast(
        position: 'bottom center',
        #         message: 'reddit done'
        #         showIcon: 'reddit'
        #         showProgress: 'bottom'
        #         class: 'success'
        #         displayTime: 'auto',
        #     )
        #     Session.set('thinking',false)



    'click .vote_up': -> 
        Docs.update @_id,
            $inc: points: 1
        # window.speechSynthesis.cancel()# 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'yeah'
    'click .vote_down': -> 
        Docs.update @_id,
            $inc: points: -1
            # window.speechSynthesis.cancel()# 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'ouch'


Template.post.events
    'click .goto_sub': -> 
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
            Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
            Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
    # 'click .call_visual': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'url', ->
    # 'click .call_meta': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'meta', ->
    # 'click .call_thumbnail': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'thumb', ->

    'click .goto_user': ->
        doc = Docs.findOne Router.current().params.doc_id
        Meteor.call 'get_user_info', doc.data.author, ->
    'click .get_post': ->
        Meteor.call 'get_reddit_post', Router.current().params.doc_id, @reddit_id, ->


Template.rcomment.events
    # console.log @data
    'click .autotag_watson': ->
        # unless @data.watson
        console.log 'calling watson on comment'
        $('body').toast(
            position: 'bottom center',
            showIcon: 'refresh'
            message: 'getting tags'
            displayTime: 'auto',
        )
        
        Meteor.call 'call_watson', @_id,'data.body','comment',(err,res)->
            if err
                # alert err.error
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'exclamation'
                    class: 'error'
                    message: 'error getting watson'
                    displayTime: 'auto',
                )
            else 
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'checkmark'
                    class: 'success'
                    message: 'autotagged', res
                    displayTime: 'auto',
                )
                
                
    'click .get_comment_emotion': ->
        $('body').toast(
            position: 'bottom center',
            showIcon: 'refresh'
            message: 'getting emotion'
            displayTime: 'auto',
        )
        Meteor.call 'get_emotion', @_id, 'comment', (err,res)->
            if err
                # alert err.error
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'exclamation'
                    class: 'error'
                    message: 'error getting emotion'
                    displayTime: 'auto',
                )
            else
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'checkmark'
                    class: 'success'
                    message: 'got emotion', res
                    displayTime: 'auto',
                )
                
        
    # unless @data.time_tags
    #     # console.log 'calling watson on comment'
    #     Meteor.call 'tagify_time_rpost', @data._id,->


# Template.reddit_post_item.events
#     'click .view_post': (e,t)-> 
#         Session.set('view_section','main')
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
#         # Router.go "/subreddit/#{@subreddit}/post/#{@_id}"

# Template.reddit_post_item.onRendered ->
#     # console.log @
#     # unless @data.watson
#     #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>

# Template.reddit_post_card.onRendered ->
#     # console.log @
#     # unless @data.watson
#     #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
#     unless @time_tags
#         Meteor.call 'tagify_time_rpost',@data._id,=>



