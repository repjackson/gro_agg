request = require('request')
rp = require('request-promise');


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
    


# Meteor.publish 'doc_by_title', (title)->
#     Docs.find({
#         title:title
#         model:'wikipedia'
#         "watson.metadata.image":$exists:true
#     }, {
#         fields:
#             title:1
#             "watson.metadata.image":1
#     })




Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
        
        
        
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> userId
    remove: (userId, doc) -> userId


