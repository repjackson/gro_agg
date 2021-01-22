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
    
    

Meteor.publish 'current_doc', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id




Meteor.publish 'doc', (doc_id)->
    found_doc = Docs.findOne doc_id
    if found_doc
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
