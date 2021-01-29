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

Meteor.publish 'wikis', (
    w_query
    selected_tags
    )->
    Docs.find({
        model:'wikipedia'
    },{ 
        limit:10
    })
    
Meteor.methods
    flatten: =>
        match = {
            model:'reddit'
            flattened:$ne:true
        }
        todo = Docs.find(match,{limit:100})
        for doc in todo.fetch()
            new_tags = _.flatten(doc.tags)
            Docs.update doc._id,
                $set:
                    flattened:true
                    tags:new_tags
    
    

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
