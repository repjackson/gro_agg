# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (user_id, doc) ->
        true
    update: (user_id, doc) ->
        true
    remove: (user_id, doc) ->
        true




Meteor.publish 'doc_by_title', (title)->
    # console.log title
    Docs.find
        title:title
        model:'wikipedia'


Meteor.publish 'current_doc', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id




Meteor.publish 'doc', (doc_id)->
    found_doc = Docs.findOne doc_id
    if found_doc
        Docs.find doc_id
    else
        Meteor.users.find doc_id





Meteor.publish 'overlap_tags', (
    query=''
    selected_tags
    target_username
    limit=20
    )->
    self = @
    match = {}
    # match.model = $in:['post','alpha']
    match.model = 'post'
    
    target_user = Meteor.users.findOne username:target_username    
    if target_user
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # match._author_id = $in:[Meteor.userId(), target_user._id]
        match.upvoter_ids = $all:[Meteor.userId(), target_user._id]

        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        tag_cloud.forEach (tag, i) ->
            self.added 'overlap', Random.id(),
                name: tag.name
                count: tag.count
                index: i
       
        self.ready()
                        


            
Meteor.publish 'global_chat', (username)->
    Docs.find {
        model:'global_chat'
    }, 
        limit:20
        sort:_timestamp:-1

Meteor.publish 'stacks', (selected_tags)->
    # user = Meteor.users.findOne username:username
    Docs.find({
        model:'stack'
        # _author_id:user._id
    },{
        limit:10
        sort:_timestamp:-1
    })
    
    
Meteor.publish 'search_doc', (selected_tags)->
    Docs.find
        model:'search'
        tags:$in:selected_tags


Meteor.publish 'overlap_docs', (
    query=''
    selected_tags
    target_username
    )->
    
    console.log target_username
    target_user = Meteor.users.findOne username:target_username    
    if target_user
        match = {}
        match.model = 'post'
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0
            match.tags = $all:selected_tags
        # if selected_authors.length > 0
        #     match._author_username = $all:selected_authors
        # match._author_id = $in:[Meteor.userId(), target_user._id]
        match.upvoter_ids = $all:[Meteor.userId(), target_user._id]
        # console.log match
        Docs.find match,
            limit:20
            sort:points:-1
                 