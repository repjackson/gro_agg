request = require('request')
rp = require('request-promise');
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> true


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
            limit: 10
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
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        
        
        self.ready()
        
        
        


Meteor.methods
    # tagify_time_rpost: (doc_id)->
    #     doc = Docs.findOne doc_id
    #     # moment.unix(doc.data.created).fromNow()
    #     # timestamp = Date.now()
    #     if doc.data and doc.data.created
    #         doc._timestamp_long = moment.unix(doc.data.created).format("dddd, MMMM Do YYYY, h:mm:ss a")
    #         # doc._app = 'dao'
        
    #         date = moment.unix(doc.data.created).format('Do')
    #         weekdaynum = moment.unix(doc.data.created).isoWeekday()
    #         weekday = moment().isoWeekday(weekdaynum).format('dddd')
        
    #         hour = moment.unix(doc.data.created).format('h')
    #         minute = moment.unix(doc.data.created).format('m')
    #         ap = moment.unix(doc.data.created).format('a')
    #         month = moment.unix(doc.data.created).format('MMMM')
    #         year = moment.unix(doc.data.created).format('YYYY')
        
    #         # doc.points = 0
    #         # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    #         date_array = [ap, weekday, month, date, year]
    #         if _
    #             date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    #             doc.timestamp_tags = date_array
    #             # console.log date_array
    #             Docs.update doc_id, 
    #                 $set:time_tags:date_array
                            

Meteor.publish 'alpha_combo', (selected_tags)->
    Docs.find 
        model:'alpha'
        # query: $in: selected_tags
        query: selected_tags.toString()
        
Meteor.publish 'doc_by_id', (id)->
    Docs.find 
        _id: id
        # model:'alpha'
        # query: selected_tags.toString()
        
        
# Meteor.publish 'alpha_single', (selected_tags)->
#     Docs.find 
#         model:'alpha'
#         query: $in: selected_tags
#         # query: selected_tags.toString()

Meteor.publish 'doc_by_title', (title)->
    Docs.find({
        title:title
        model:'wikipedia'
    }, {
        fields:
            title:1
            "watson.metadata.image":1
    })

Meteor.publish 'comments', (doc_id)->
    Docs.find
        model:'comment'
        parent_id:doc_id


        
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