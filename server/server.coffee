request = require('request')
rp = require('request-promise');
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> true

Meteor.users.allow
    insert: (user_id, doc, fields, modifier) ->
        # user_id
        true
        # if user_id and doc._id == user_id
        #     true
    update: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'dev' in user.roles
            true
        else
            if user_id and doc._id == user_id
                true
    remove: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'dev' in user.roles
            true
        # if userId and doc._id == userId
        #     true


# Meteor.publish 'model_count', (
#     model
#     )->
#     match = {model:model}
    
#     Counts.publish this, 'model_counter', Docs.find(match)
#     return undefined


Meteor.methods
    # hi: ->
    # stringify_tags: ->
    #     docs = Docs.find({
    #         tags: $exists: true
    #         tags_string: $exists: false
    #     },{limit:1000})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         tags_string = doc.tags.toString()
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #
    log_view: (doc_id)->
        # console.log 'logging view', doc_id
        Docs.update doc_id, 
            $inc:views:1
        if Meteor.userId()
            Docs.update doc_id,
                $addToSet:viewer_ids:Meteor.userId()


    # log_term: (term_title)->
    #     found_term =
    #         Terms.findOne
    #             title:term_title
    #     unless found_term
    #         Terms.insert
    #             title:term_title
    #         # if Meteor.user()
    #         #     Meteor.users.update({_id:Meteor.userId()},{$inc: karma: 1}, -> )
    #     else
    #         Terms.update({_id:found_term._id},{$inc: count: 1}, -> )
    #         Meteor.call 'call_wiki', @term_title, =>
    #             Meteor.call 'calc_term', @term_title, ->

    # calc_term: (term_title)->
    #     found_term =
    #         Terms.findOne
    #             title:term_title
    #     unless found_term
    #         Terms.insert
    #             title:term_title
    #     if found_term
    #         found_term_docs =
    #             Docs.find {
    #                 model:'reddit'
    #                 tags:$in:[term_title]
    #             }, {
    #                 sort:
    #                     points:-1
    #                     ups:-1
    #                 limit:10
    #             }



    #         unless found_term.image
    #             found_wiki_doc =
    #                 Docs.findOne
    #                     model:$in:['wikipedia']
    #                     # model:$in:['wikipedia','reddit']
    #                     title:term_title
    #             found_reddit_doc =
    #                 Docs.findOne
    #                     model:$in:['reddit']
    #                     "watson.metadata.image": $exists:true
    #                     # model:$in:['wikipedia','reddit']
    #                     title:term_title
    #             if found_wiki_doc
    #                 if found_wiki_doc.watson.metadata.image
    #                     Terms.update term._id,
    #                         $set:image:found_wiki_doc.watson.metadata.image

Meteor.methods
    # hi: ->
    # stringify_tags: ->
    #     docs = Docs.find({
    #         tags: $exists: true
    #         tags_string: $exists: false
    #     },{limit:500})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         tags_string = doc.tags.toString()
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #

Meteor.publish 'count', (
    picked_tags
    toggle
    )->
    match = {
        model:'rpost'
    }

    match.tags = $all:picked_tags
    if picked_tags.length
        Counts.publish this, 'counter', Docs.find(match)
        return undefined
            
Meteor.publish 'posts', (
    picked_tags
    toggle
    porn_mode
    )->
    self = @
    match = {
        model:'rpost'
    }
    if picked_tags.length
        match.tags = $all:picked_tags
        match["data.over_18"] = porn_mode
    
        # console.log 'match', match
        Docs.find match,
            limit: 20
            # sort: "#{sk}":-1
            sort: ups:-1
            fields:
                "data.title":1
                "data.subreddit":1
                "data.thumbnail_width":1
                "data.thumbnail":1
                "data.media":1
                "data.selftext_html":1
                "data.created":1
                "subreddit":1
                tags:1
                url:1
                model:1
                ups:1
                domain:1
                # data:1
    
    
           
Meteor.publish 'tags', (
    picked_tags
    toggle
    porn_mode
    )->
    # @unblock()
    self = @
    match = {
        model: 'rpost'
    }
    if picked_tags.length
        match.tags = $all:picked_tags
        match["data.over_18"] = porn_mode

        doc_count = Docs.find(match).count()
        # console.log 'doc_count', doc_count
        # console.log 'tag match', match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        
        
        self.ready()
        
        
        


Meteor.publish 'alpha_combo', (selected_tags)->
    Docs.find 
        model:'alpha'
        # query: $in: selected_tags
        query: selected_tags.toString()
        
        
# Meteor.publish 'alpha_single', (selected_tags)->
#     Docs.find 
#         model:'alpha'
#         query: $in: selected_tags
#         # query: selected_tags.toString()

        
Meteor.publish 'duck', (selected_tags)->
    Docs.find 
        model:'duck'
        # query: $in: selected_tags
        query: selected_tags.toString()
        
        
Meteor.methods
    call_alpha: (query)->
        # @unblock()
        found_alpha = 
            Docs.findOne 
                model:'alpha'
                query:query
        if found_alpha
            target = found_alpha
            # if target.updated
            #     return target
        else
            target_id = 
                Docs.insert
                    model:'alpha'
                    query:query
                    tags:[query]
            target = Docs.findOne target_id       
                   
                    
        HTTP.get "http://api.wolframalpha.com/v1/spoken?i=#{query}&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            if response
                Docs.update target._id,
                    $set:
                        voice:response.content  
            # HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=3&format=html,image,plaintext,sound&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=5&format=html,image,plaintext&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
                if response
                    parsed = JSON.parse(response.content)
                    Docs.update target._id,
                        $set:
                            response:parsed  
                            updated:true
                                    
                                    
                            
    add_chat: (chat)->
        @unblock()
        # now = Date.now()
        # found_last_chat = 
        #     Docs.findOne { 
        #         model:'global_chat'
        #         _timestamp: $lt:now
        #     }, limit:1
        # new_id = 
        #     Docs.insert 
        #         model:'global_chat'
        #         body:chat
        #         bot:false
        HTTP.get "http://api.wolframalpha.com/v1/conversation.jsp?appid=UULLYY-QR2ALYJ9JU&i=#{chat}",(err,res)=>
            if res
                parsed = JSON.parse(res.content)
                Docs.insert
                    model:'global_chat'
                    bot:true
                    res:parsed
                return parsed
                
                
    arespond: (post_id)->
        # @unblock()
        post = Docs.findOne post_id
        # now = Date.now()
        # found_last_chat = 
        #     Docs.findOne { 
        #         model:'global_chat'
        #         _timestamp: $lt:now
        #     }, limit:1
        # new_id = 
        #     Docs.insert 
        #         model:'global_chat'
        #         body:chat
        #         bot:false
        HTTP.get "http://api.wolframalpha.com/v1/conversation.jsp?appid=UULLYY-QR2ALYJ9JU&i=#{post.body}",(err,response)=>
            if response
                parsed = JSON.parse(response.content)
                Docs.insert
                    model:'alpha_response'
                    bot:true
                    response:parsed
                    parent_id:post_id