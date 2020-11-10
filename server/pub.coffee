Meteor.publish 'user_from_username', (username)->
    # console.log 'pulling doc'
    Meteor.users.find
        username:username
        
Meteor.publish 'user_friends', (username)->
    # console.log 'pulling doc'
    user = 
        Meteor.users.findOne
            username:username
    if user
        if user.friend_ids
            Meteor.users.find 
                _id: $in: user.friend_ids
Meteor.publish 'my_friends', ()->
    # console.log 'pulling doc'
    if Meteor.user().friend_ids
        Meteor.users.find 
            _id: $in: Meteor.user().friend_ids
Meteor.publish 'user_model_docs', (model,username)->
    # console.log 'pulling doc'
    user = Meteor.users.findOne username:username
    if user
        Docs.find
            model:model
            _author_id:user._id

        
Meteor.publish 'question_bounties', (question_id)->
    Docs.find 
        model:'bounty'
        question_id:question_id
        
Meteor.publish 'all_questions', (question_id)->
    Docs.find 
        model:'question'
        # question_id:question_id
            
            

Meteor.publish 'questions', (
    selected_tags
    query
    view_open
    view_your_questions
    view_your_answers
    )->
    # console.log 'pulling question'
    # user = Meteor.users.findOne username:username
    match = {model:'question'}
    if view_open
        match.open = true
    if view_your_questions
        match._author_id = Meteor.userId()
    if view_your_answers
        match.answer_user_ids = $in:[Meteor.userId()]
    if query and query.length > 0
        match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags and selected_tags.length > 0
        match.tags = $all: selected_tags

    Docs.find match

Meteor.publish 'user_log_events', (username)->
    # console.log 'pulling doc'
    user = Meteor.users.findOne username:username
    Docs.find {
        model:'log_event'
        _author_id:user._id
    }, limit:20


Meteor.publish 'recipient_from_debit_id', (debit_id)->
    # console.log 'pulling doc'
    debit = Docs.findOne debit_id
    Meteor.users.find
        _id:debit.recipient_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    # console.log 'pulling doc'
    doc = Docs.findOne doc_id
    Meteor.users.find
        _id:doc._author_id

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find
        _id:user_id

Meteor.publish 'doc_comments', (doc_id)->
    Docs.find
        model:'comment'
        parent_id:doc_id


Meteor.publish 'children', (model, parent_id)->
    match = {}
    Docs.find
        model:model
        parent_id:parent_id

Meteor.publish 'current_doc', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id



Meteor.publish 'model_docs', (model)->
    # console.log 'pulling doc'
    match = {model:model}
    # if Meteor.user()
    #     unless Meteor.user().roles and 'admin' in Meteor.user().roles
    #         match.app = 'stand'
    # else
        # match.app = 'stand'
    Docs.find match

Meteor.publish 'latest_debits', ()->
    # console.log 'pulling doc'
    match = {model:'debit'}
    # if Meteor.user()
    #     unless Meteor.user().roles and 'admin' in Meteor.user().roles
    #         match.app = 'stand'
    # else
        # match.app = 'stand'
    Docs.find match,
        sort:_timestamp:-1
        limit:25


Meteor.publish 'all_users', ()->
    Meteor.users.find()

Meteor.publish 'my_unread_messages', ()->
    Docs.find
        model:'message'
        read:false



Meteor.publish 'doc', (doc_id)->
    found_doc = Docs.findOne doc_id
    if found_doc
        Docs.find doc_id
    else
        Meteor.users.find doc_id




Meteor.publish 'me', ()->
    if Meteor.user()
        Meteor.users.find Meteor.userId()
    else
        []
# if date_setting
#     if date_setting is 'today'
#         now = Date.now()
#         day = 24*60*60*1000
#         yesterday = now-day
#         # console.log yesterday
#         match._timestamp = $gt:yesterday



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
                 