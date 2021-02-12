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
    #     },{limit:1000})
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
    selected_tags
    )->
    Docs.find({
        model:'wikipedia'
    },{ 
        limit:10
    })
    


Meteor.publish 'doc_by_title', (title)->
    Docs.find
        title:title
        model:'wikipedia'

Meteor.publish 'doc_by_title_small', (title)->
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



Meteor.publish 'doc_comments', (doc_id)->
    Docs.find
        model:'comment'
        parent_id:doc_id



Meteor.publish 'current_doc', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id


Meteor.publish 'doc', (doc_id)->
    found_doc = Docs.findOne doc_id
    if found_doc
        Docs.find doc_id



# Meteor.publish 'tag_results', (
#     # doc_id
#     selected_tags
#     searching
#     query
#     dummy
#     )->
#     # console.log 'dummy', dummy
#     console.log 'selected tags', selected_tags
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
#         #     { $match: _id: $nin: selected_tags }
#         #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
#         #     { $sort: count: -1, _id: 1 }
#         #     { $limit: 42 }
#         #     { $project: _id: 0, name: '$_id', count: 1 }
#         #     ]

#     else
#         # unless query and query.length > 2
#         # if selected_tags.length > 0 then match.tags = $all: selected_tags
#         # console.log date_setting
#         # if date_setting
#         #     if date_setting is 'today'
#         #         now = Date.now()
#         #         day = 24*60*60*1000
#         #         yesterday = now-day
#         #         console.log yesterday
#         #         match._timestamp = $gt:yesterday


#         # debit = Docs.findOne doc_id
#         if selected_tags.length > 0
#             # match.tags = $all: debit.tags
#             match.tags = $all: selected_tags
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
#                 { $match: _id: $nin: selected_tags }
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
#     selected_tags
#     selected_subreddits
#     selected_domains
#     selected_authors
#     selected_emotions
#     date_setting
#     )->
#     # console.log 'got selected tags', selected_tags
#     # else
#     self = @
#     match = {model:$in:['reddit','wikipedia']}
#     # if selected_tags.length > 0
#     # console.log date_setting
#     if date_setting
#         if date_setting is 'today'
#             now = Date.now()
#             day = 24*60*60*1000
#             yesterday = now-day
#             # console.log yesterday
#             match._timestamp = $gt:yesterday

#     if selected_tags.length > 0
#         # if selected_tags.length is 1
#         #     console.log 'looking single doc', selected_tags[0]
#         #     found_doc = Docs.findOne(title:selected_tags[0])
#         #
#         #     match.title = selected_tags[0]
#         # else
#         match.tags = $all: selected_tags
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
#         limit:10            