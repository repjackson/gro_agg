if Meteor.isClient
    Template.rpage.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
        @autorun -> Meteor.subscribe('rpost_comments', Router.current().params.group, Router.current().params.doc_id)
        Session.setDefault('view_section','comments')
        
    Template.rpage.onRendered ->
        Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->
        Meteor.call 'get_reddit_post', Router.current().params.doc_id, ->
        Meteor.call 'call_watson',Router.current().params.doc_id,'url','url',=>

    Template.rpage.helpers
        rpost_comments: ->
            post = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'rcomment'
                parent_id:"t3_#{post.reddit_id}"
    
    Template.rcomments_tab.helpers
        rpost_comments: ->
            post = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'rcomment'
                parent_id:"t3_#{post.reddit_id}"
    Template.rpage.events
        'click .get_comments': -> Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->
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
            #     showIcon: 'reddit'
            #     message: 'reddit started'
            #     displayTime: 'auto',
            # )
            # Meteor.call 'search_reddit', selected_tags.array(), ->
            #     $('body').toast(
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

    
    Template.rpage.events
        'click .goto_sub': -> 
            Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
                Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
                Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
        # 'click .call_visual': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'url', ->
        # 'click .call_meta': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'meta', ->
        # 'click .call_thumbnail': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'thumb', ->

        'click .goto_ruser': ->
            doc = Docs.findOne Router.current().params.doc_id
            Meteor.call 'get_user_info', doc.data.author, ->
        'click .get_post': ->
            Session.set('view_section','main')
            Meteor.call 'get_reddit_post', Router.current().params.doc_id, @reddit_id, ->
  
  
    Template.rcomment.onRendered ->
        # console.log @data
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->
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
    


if Meteor.isServer
    Meteor.publish 'rpost_comment_tags', (
        subreddit
        parent_id
        picked_tags
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        
        parent = Docs.findOne parent_id
        
        self = @
        match = {
            model:'rcomment'
            parent_id:"t3_#{parent.reddit_id}"
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        # if picked_tags.length > 0 then match.tags = $all:picked_tags
        # if picked_emotion.length > 0 then match.max_emotion_name = picked_emotion
        doc_count = Docs.find(match).count()
        rpost_comment_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:11 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        rpost_comment_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'rpost_comment_tag'
                
        self.ready()
    Meteor.publish 'related_posts', (post_id)->
        post = Docs.findOne post_id
            
        related_cur = 
            Docs.find({
                model:'rpost'
                subreddit:post.subreddit
                tags:$in:post.tags
                _id:$ne:post._id
            },{ 
                limit:10
                sort:"data.ups":-1
            })
        related_cur
        
                
    Meteor.publish 'rpost_comments', (subreddit, doc_id)->
        post = Docs.findOne doc_id
        Docs.find
            model:'rcomment'
            parent_id:"t3_#{post.reddit_id}"
            
            
        
        
    Meteor.methods
        tagify_time_rpost: (doc_id)->
            doc = Docs.findOne doc_id
            # moment.unix(doc.data.created).fromNow()
            # timestamp = Date.now()
    
            doc._timestamp_long = moment.unix(doc.data.created).format("dddd, MMMM Do YYYY, h:mm:ss a")
            # doc._app = 'dao'
        
            date = moment.unix(doc.data.created).format('Do')
            weekdaynum = moment.unix(doc.data.created).isoWeekday()
            weekday = moment().isoWeekday(weekdaynum).format('dddd')
        
            hour = moment.unix(doc.data.created).format('h')
            minute = moment.unix(doc.data.created).format('m')
            ap = moment.unix(doc.data.created).format('a')
            month = moment.unix(doc.data.created).format('MMMM')
            year = moment.unix(doc.data.created).format('YYYY')
        
            # doc.points = 0
            # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
            date_array = [ap, weekday, month, date, year]
            if _
                date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
                doc._timestamp_tags = date_array
                Docs.update doc_id, 
                    $set:time_tags:date_array
                            
