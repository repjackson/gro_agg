# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> true

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
    #     },{limit:500})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         tags_string = doc.tags.toString()
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #
    log_view: (doc_id)->
        console.log 'logging view', doc_id
        Docs.update doc_id, 
            $inc:views:1
            
            
            
    remove_doc: (doc_id)->
        console.log 'removing doc', doc_id
        Docs.remove doc_id
        
        
    log_doc_terms: (doc_id)->
        doc = Docs.findOne doc_id
        if doc.tags
            for tag in doc.tags
                Meteor.call 'log_term', tag, ->


    rename_key:(old_key,new_key,parent)->
        Docs.update parent._id,
            $pull:_keys:old_key
        Docs.update parent._id,
            $addToSet:_keys:new_key
        Docs.update parent._id,
            $rename:
                "#{old_key}": new_key
                "_#{old_key}": "_#{new_key}"

    remove_tag: (tag)->
        results =
            Docs.find {
                tags: $in: [tag]
            }
        # Docs.remove(
        #     tags: $in: [tag]
        # )
        for doc in results.fetch()
            res = Docs.update doc._id,
                $pull: tags: tag


    # import_tests: ->
    #     # myobject = HTTP.get(Meteor.absoluteUrl("/public/tests.json")).data;
    #     myjson = JSON.parse(Assets.getText("tests.json"));
    #     console.log myjson


    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id            
            
            
Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
        
Meteor.publish 'love', (doc_id)->
    Docs.find
        model:'love'
        

Meteor.publish 'wikis', (
    w_query
    picked_tags
    )->
    Docs.find({
        model:'wikipedia'
    },{ 
        limit:5
    })
    


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



# Meteor.publish 'tag_results', (
#     # doc_id
#     picked_tags
#     searching
#     query
#     dummy
#     )->
#     # console.log 'dummy', dummy
#     console.log 'selected tags', picked_tags
#     console.log 'query', query

#     self = @
#     match = {}

#     match.model = $in: ['debit']
#     # console.log 'query length', query.length
#     # if query
#     # if query and query.length > 1
#     if query.length > 1
#         console.log 'searching query', query
#         # #     # match.tags = {$regex:"#{query}", $options: 'i'}
#         # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
#         # #
#         terms = Terms.find({
#             # title: {$regex:"#{query}"}
#             title: {$regex:"#{query}", $options: 'i'}
#             app:'stand'
#         },
#             sort:
#                 count: -1
#             limit: 5
#         )
#         # console.log terms.fetch()
#         # tag_cloud = Docs.aggregate [
#         #     { $match: match }
#         #     { $project: "tags": 1 }
#         #     { $unwind: "$tags" }
#         #     { $group: _id: "$tags", count: $sum: 1 }
#         #     { $match: _id: $nin: picked_tags }
#         #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
#         #     { $sort: count: -1, _id: 1 }
#         #     { $limit: 42 }
#         #     { $project: _id: 0, name: '$_id', count: 1 }
#         #     ]

#     else
#         # unless query and query.length > 2
#         # if picked_tags.length > 0 then match.tags = $all: picked_tags
#         # console.log date_setting
#         # if date_setting
#         #     if date_setting is 'today'
#         #         now = Date.now()
#         #         day = 24*60*60*1000
#         #         yesterday = now-day
#         #         console.log yesterday
#         #         match._timestamp = $gt:yesterday


#         # debit = Docs.findOne doc_id
#         if picked_tags.length > 0
#             # match.tags = $all: debit.tags
#             match.tags = $all: picked_tags
#             # else
#             #     # unless selected_domains.length > 0
#             #     #     unless selected_subreddits.length > 0
#             #     #         unless selected_subreddits.length > 0
#             #     #             unless selected_emotions.length > 0
#             #     match.tags = $all: ['dao']
#             # console.log 'match for tags', match
#             # if selected_subreddits.length > 0
#             #     match.subreddit = $all: selected_subreddits
#             # if selected_domains.length > 0
#             #     match.domain = $all: selected_domains
#             # if selected_emotions.length > 0
#             #     match.max_emotion_name = $all: selected_emotions
#             console.log 'match for tags', match
    
    
#             agg_doc_count = Docs.find(match).count()
#             tag_cloud = Docs.aggregate [
#                 { $match: match }
#                 { $project: "tags": 1 }
#                 { $unwind: "$tags" }
#                 { $group: _id: "$tags", count: $sum: 1 }
#                 { $match: _id: $nin: picked_tags }
#                 { $match: count: $lt: agg_doc_count }
#                 # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
#                 { $sort: count: -1, _id: 1 }
#                 { $limit: 10 }
#                 { $project: _id: 0, name: '$_id', count: 1 }
#             ], {
#                 allowDiskUse: true
#             }
    
#             tag_cloud.forEach (tag, i) =>
#                 # console.log 'queried tag ', tag
#                 # console.log 'key', key
#                 self.added 'tags', Random.id(),
#                     title: tag.name
#                     count: tag.count
#                     # category:key
#                     # index: i
#             # console.log doc_tag_cloud.count()

#         self.ready()

# Meteor.publish 'doc_results', (
#     picked_tags
#     selected_subreddits
#     selected_domains
#     selected_authors
#     selected_emotions
#     date_setting
#     )->
#     # console.log 'got selected tags', picked_tags
#     # else
#     self = @
#     match = {model:$in:['reddit','wikipedia']}
#     # if picked_tags.length > 0
#     # console.log date_setting
#     if date_setting
#         if date_setting is 'today'
#             now = Date.now()
#             day = 24*60*60*1000
#             yesterday = now-day
#             # console.log yesterday
#             match._timestamp = $gt:yesterday

#     if picked_tags.length > 0
#         # if picked_tags.length is 1
#         #     console.log 'looking single doc', picked_tags[0]
#         #     found_doc = Docs.findOne(title:picked_tags[0])
#         #
#         #     match.title = picked_tags[0]
#         # else
#         match.tags = $all: picked_tags
#     else
#         # unless selected_domains.length > 0
#         #     unless selected_subreddits.length > 0
#         #         unless selected_subreddits.length > 0
#         #             unless selected_emotions.length > 0
#         match.tags = $all: ['dao']
#     if selected_domains.length > 0
#         match.domain = $all: selected_domains

#     if selected_subreddits.length > 0
#         match.subreddit = $all: selected_subreddits
#     if selected_emotions.length > 0
#         match.max_emotion_name = $all: selected_emotions

#     # else
#     #     match.tags = $nin: ['wikipedia']
#     #     sort = '_timestamp'
#     #     # match. = $ne:'wikipedia'
#     # console.log 'doc match', match
#     # console.log 'sort key', sort_key
#     # console.log 'sort direction', sort_direction
#     Docs.find match,
#         sort:
#             points:-1
#             ups:-1
#         limit:5      



Meteor.publish 'count', (
    group
    picked_tags
    picked_time_tags
    picked_location_tags
    )->
    match = {model:$in:['post','rpost']}
    # match.group = group
    match.group_lowered = group.toLowerCase()
        
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags
    Counts.publish this, 'counter', Docs.find(match)
    return undefined
            
Meteor.publish 'posts', (
    group
    picked_tags
    picked_time_tags
    picked_location_tags
    picked_Persons
    picked_Locations
    picked_Organizations
    sort_key
    sort_direction
    skip=0
    toggle
    )->
    self = @
    match = {
        model:$in:['post','rpost']
        # group: group
    }
    # if group is 'all'
    #     match.group = $exists:false
    # else
    # match.group = group
    self = @
    match = {
        # group:group
        # subgroup:subgroup
    }
    # match.group = group
    if group
        match.group_lowered = group.toLowerCase()
        match.model = $in: ['post','rpost']
    else
        match.model = $in: ['rpost']
    

    if sort_key
        sk = sort_key
    else
        sk = '_timestamp'
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags
    if picked_Persons.length > 0 then match.Person = $all:picked_Persons
    if picked_Locations.length > 0 then match.Location = $all:picked_Locations
    if picked_Organizations.length > 0 then match.Organization = $all:picked_Organizations
    # console.log 'skip', skip
    Docs.find match,
        limit: 10
        sort: "#{sk}":-1
        fields:
            tags:1
            title:1
            model:1
            "data.title":1
            group:1
            time_tags:1
            _timestamp:1
            group_lowered:1
            image_id:1
            youtube_id:1
            "watson.metadata.image":1
            watson:1
            "data.url":1
            "data.thumbnail":1
            "data.domain":1
            "data.ups":1
            "data.num_comments":1
            "data.created":1
            "data.media":1
            # analyzed_text:response.analyzed_text
            # watson: response
            max_emotion_name:1
            max_emotion_percent:1
            sadness_percent: 1
            joy_percent: 1
            fear_percent: 1
            anger_percent: 1
            disgust_percent: 1
            watson_concepts: 1
            watson_keywords: 1
            "doc_sentiment_score": 1
            "doc_sentiment_label": 1
            
        # skip:skip*20
    
    
Meteor.methods    
    lower_group: (group)->
        @unblock()
        cursor = 
            Docs.find
                model:$in:['rpost','post']
                group:group
                group_lowered:$exists:false
                
                
        console.log 'unlowered doc count', cursor.count()
        for doc in cursor.fetch()
            Docs.update doc._id,
                $set:group_lowered:doc.group.toLowerCase()
            console.log 'lowered', doc.group, doc._id
        # doc = Docs.findOne group
        # # moment(doc.date).fromNow()
        # # timestamp = Date.now()

        # doc._timestamp_long = moment(doc._timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
        # doc._app = 'group'
    
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
    
           
Meteor.publish 'tags', (
    group
    picked_tags
    picked_time_tags
    picked_location_tags
    picked_Persons
    picked_Locations
    picked_Organizations
    toggle
    )->
    # @unblock()
    self = @
    match = {
        # group:group
        # subgroup:subgroup
    }
    # match.group = group
    if group
        match.group_lowered = group.toLowerCase()
        match.model = $in: ['post','rpost']
    else
        match.model = $in: ['rpost']
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    # if picked_subgroup_domain.length > 0 then match.domain = $all:picked_subgroup_domain
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags
    if picked_Persons.length > 0 then match.Person = $all:picked_Persons
    if picked_Locations.length > 0 then match.Location = $all:picked_Locations
    if picked_Organizations.length > 0 then match.Organization = $all:picked_Organizations
    doc_count = Docs.find(match).count()
    console.log 'doc_count', doc_count
    console.log 'tag match', match
    group_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:15 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    group_tag_cloud.forEach (tag, i) ->
        # console.log tag
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'tag'
    
    
    # group_domain_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "data.domain": 1 }
    #     # { $unwind: "$domain" }
    #     { $group: _id: "$data.domain", count: $sum: 1 }
    #     # { $match: _id: $nin: picked_domains }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # group_domain_cloud.forEach (domain, i) ->
    #     self.added 'results', Random.id(),
    #         name: domain.name
    #         count: domain.count
    #         model:'group_domain_tag'
    
    
    group_location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        { $unwind: "$location_tags" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        # { $match: _id: $nin: picked_location }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:5 }
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
        { $limit:5 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    group_time_cloud.forEach (time_tag, i) ->
        self.added 'results', Random.id(),
            name: time_tag.name
            count: time_tag.count
            model:'time_tag'
  
    group_Location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Location": 1 }
        { $unwind: "$Location" }
        { $group: _id: "$Location", count: $sum: 1 }
        { $match: _id: $nin: picked_time_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:5 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    group_Location_cloud.forEach (Location, i) ->
        self.added 'results', Random.id(),
            name: Location.name
            count: Location.count
            model:'Location'
  
    group_Person_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Person": 1 }
        { $unwind: "$Person" }
        { $group: _id: "$Person", count: $sum: 1 }
        { $match: _id: $nin: picked_time_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:5 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    group_Person_cloud.forEach (Person, i) ->
        self.added 'results', Random.id(),
            name: Person.name
            count: Person.count
            model:'Person'
  
    # group_Organization_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Organization": 1 }
    #     { $unwind: "$Organization" }
    #     { $group: _id: "$Organization", count: $sum: 1 }
    #     { $match: _id: $nin: picked_time_tags }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # group_Organization_cloud.forEach (Organization, i) ->
    #     self.added 'results', Random.id(),
    #         name: Organization.name
    #         count: Organization.count
    #         model:'Organization'
  
    # group_HealthCondition_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "HealthCondition": 1 }
    #     { $unwind: "$HealthCondition" }
    #     { $group: _id: "$HealthCondition", count: $sum: 1 }
    #     { $match: _id: $nin: picked_time_tags }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # group_HealthCondition_cloud.forEach (HealthCondition, i) ->
    #     self.added 'results', Random.id(),
    #         name: HealthCondition.name
    #         count: HealthCondition.count
    #         model:'HealthCondition'
  
    # group_HealthCondition_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "HealthCondition": 1 }
    #     { $unwind: "$HealthCondition" }
    #     { $group: _id: "$HealthCondition", count: $sum: 1 }
    #     { $match: _id: $nin: picked_time_tags }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # group_HealthCondition_cloud.forEach (time_tag, i) ->
    #     self.added 'results', Random.id(),
    #         name: HealthCondition.name
    #         count: HealthCondition.count
    #         model:'HealthCondition'
  
    self.ready()
        