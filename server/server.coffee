Meteor.methods
    remove_doc: (doc_id)->
        Docs.remove doc_id

        

# Meteor.publish 'wikis', (
#     w_query
#     picked_tags
#     )->
#     Docs.find({
#         model:'wikipedia'
#     },{ 
#         limit:10
#     })
    


# Meteor.publish 'try', (title)->
#     Docs.find {
#         model:'rpost'
#     }, limit:10    

Meteor.publish 'doc_by_title', (title)->
    @unblock()
    Docs.find({
        title:title
        model:'wikipedia'
        "metadata.image":$exists:true
    }, {
        fields:
            title:1
            "metadata.image":1
            model:1
    })




Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
        
Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
        
Meteor.publish 'children', (model,parent_id)->
    Docs.find 
        model:model
        parent_id:parent_id
        
        
        
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> false



Meteor.publish 'alpha_combo', (picked_tags)->
    @unblock()
    Docs.find 
        model:'alpha'
        # query: $in: picked_tags
        query: picked_tags.toString()
Meteor.methods
    call_alpha: (query)->
        @unblock()
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
                            
                            
Meteor.publish 'group_count', (
    group
    picked_tags
    picked_time_tags
    selected_location_tags
    selected_people_tags
    picked_timestamp_tags
    )->
    match = {model:'post'}
    if group is 'all'
        match.group = $exists:false
    else
        match.group = group
        
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    if selected_people_tags.length > 0 then match.people_tags = $all:selected_people_tags

    Counts.publish this, 'counter', Docs.find(match)
    return undefined
            
Meteor.publish 'group_posts', (
    group
    picked_tags
    picked_time_tags
    selected_location_tags
    selected_people_tags
    picked_max_emotion
    picked_timestamp_tags
    sort_key='_timestamp'
    sort_direction
    skip=0
    )->
    self = @
    match = {
        model:'post'
        # group: group
    }
    if group is 'all'
        match.group = $exists:false
    else
        match.group = group

    if picked_max_emotion.length > 0 then match.max_emotion_name = $all:picked_max_emotion

    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    if selected_people_tags.length > 0 then match.people_tags = $all:selected_people_tags
    if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags
    # if selected_group_authors.length > 0 then match.author = $all:selected_group_authors
    # console.log 'skip', skip
    Docs.find match,
        limit:10
        sort: "#{sort_key}":-1
        skip:skip*10
        fields:
            title:1
            content:1
            group:1
            tone:1
            tags:1
            time_tags:1
            location_tags:1
            people_tags:1
            views:1
            points:1
            max_emotion_name:1
            doc_sentiment_label:1
            doc_sentiment_score:1
            image_link:1
            image_id:1
            model:1
            _timestamp:1
            youtube_id:1
            joy_percent:1
            sadness_percent:1
            fear_percent:1
            disgust_percent:1
            anger_percent:1
    
    
# Meteor.methods    
    # tagify_group: (group)->
    #     doc = Docs.findOne group
    #     # moment(doc.date).fromNow()
    #     # timestamp = Date.now()

    #     doc._timestamp_long = moment(doc._timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    #     # doc._app = 'group'
    
    #     date = moment(doc.date).format('Do')
    #     weekdaynum = moment(doc.date).isoWeekday()
    #     weekday = moment().isoWeekday(weekdaynum).format('dddd')
    
    #     hour = moment(doc.date).format('h')
    #     minute = moment(doc.date).format('m')
    #     ap = moment(doc.date).format('a')
    #     month = moment(doc.date).format('MMMM')
    #     year = moment(doc.date).format('YYYY')
    
    #     # doc.points = 0
    #     # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    #     date_array = [ap, weekday, month, date, year]
    #     if _
    #         date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    #         doc._timestamp_tags = date_array
    #         # console.log 'group', date_array
    #         Docs.update group, 
    #             $set:addedtime_tags:date_array
    
           
Meteor.publish 'group_tags', (
    group
    picked_tags
    picked_time_tags
    selected_location_tags
    selected_people_tags
    picked_max_emotion
    picked_timestamp_tags
    # view_bounties
    # view_unanswered
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'post'
        # group:group
        # subgroup:subgroup
    }
    if group is 'all'
        match.group = $exists:false
    else
        match.group = group

    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_max_emotion.length > 0 then match.max_emotion_name = $all:picked_max_emotion
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    if selected_people_tags.length > 0 then match.people_tags = $all:selected_people_tags
    if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags
    # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    group_tag_cloud = Docs.aggregate [
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
    group_tag_cloud.forEach (tag, i) ->
        # console.log tag
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'group_tag'
    
    
    group_people_cloud = Docs.aggregate [
        { $match: match }
        { $project: "people_tags": 1 }
        { $unwind: "$people_tags" }
        { $group: _id: "$people_tags", count: $sum: 1 }
        # { $match: _id: $nin: selected_people_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    group_people_cloud.forEach (people, i) ->
        self.added 'results', Random.id(),
            name: people.name
            count: people.count
            model:'people_tag'
    
    
    group_location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        { $unwind: "$location_tags" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        # { $match: _id: $nin: selected_location_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    group_location_cloud.forEach (location, i) ->
        self.added 'results', Random.id(),
            name: location.name
            count: location.count
            model:'location_tag'
    
    
    
    group_time_cloud = Docs.aggregate [
        { $match: match }
        { $project: "time_tags": 1 }
        { $unwind: "$time_tags" }
        { $group: _id: "$time_tags", count: $sum: 1 }
        { $match: _id: $nin: picked_time_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    group_time_cloud.forEach (time_tag, i) ->
        self.added 'results', Random.id(),
            name: time_tag.name
            count: time_tag.count
            model:'time_tag'
  
    emotion_cloud = Docs.aggregate [
        { $match: match }
        { $project: "max_emotion_name": 1 }
        # { $unwind: "$max_emotion_name" }
        { $group: _id: "$max_emotion_name", count: $sum: 1 }
        { $match: _id: $nin: picked_time_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    emotion_cloud.forEach (emotion, i) ->
        self.added 'results', Random.id(),
            name: emotion.name
            count: emotion.count
            model:'emotion'
  
    timestamp_cloud = Docs.aggregate [
        { $match: match }
        { $project: "_timestamp_tags": 1 }
        { $unwind: "$_timestamp_tags" }
        { $group: _id: "$_timestamp_tags", count: $sum: 1 }
        { $match: _id: $nin: picked_timestamp_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    timestamp_cloud.forEach (timestamp, i) ->
        self.added 'results', Random.id(),
            name: timestamp.name
            count: timestamp.count
            model:'timestamp_tag'
  
    self.ready()
                                    
                                    
Meteor.publish 'agg_sentiment_group', (
    group
    picked_tags
    picked_time_tags
    selected_location_tags
    selected_people_tags
    picked_max_emotion
    picked_timestamp_tags
    )->
    # @unblock()
    self = @
    match = {
        model:$in:['post']
        group:group
        joy_percent:$exists:true
    }
        
    doc_count = Docs.find(match).count()
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_max_emotion.length > 0 then match.max_emotion_name = $all:picked_max_emotion
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    if selected_people_tags.length > 0 then match.people_tags = $all:selected_people_tags
    if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags
    
    emotion_avgs = Docs.aggregate [
        { $match: match }
        #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
        { $group: 
            _id:null
            avg_sent_score: { $avg: "$doc_sentiment_score" }
            avg_joy_score: { $avg: "$joy_percent" }
            avg_anger_score: { $avg: "$anger_percent" }
            avg_sadness_score: { $avg: "$sadness_percent" }
            avg_disgust_score: { $avg: "$disgust_percent" }
            avg_fear_score: { $avg: "$fear_percent" }
        }
    ]
    emotion_avgs.forEach (res, i) ->
        self.added 'results', Random.id(),
            model:'emotion_avg'
            avg_sent_score: res.avg_sent_score
            avg_joy_score: res.avg_joy_score
            avg_anger_score: res.avg_anger_score
            avg_sadness_score: res.avg_sadness_score
            avg_disgust_score: res.avg_disgust_score
            avg_fear_score: res.avg_fear_score
    self.ready()    
                                
                                