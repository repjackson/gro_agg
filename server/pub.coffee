# Meteor.publish 'model_count', (
#     model
#     )->
#     match = {model:model}
    
#     Counts.publish this, 'model_counter', Docs.find(match)
#     return undefined


Meteor.publish 'qid', (site,qid)->
    Docs.find 
        model:'stack_question'
        question_id:parseInt(qid)
        site:site
Meteor.publish 'q_c', (site,qid)->
    Docs.find 
        model:'stack_comment'
        post_id:parseInt(qid)
        site:site
# Meteor.publish 'question_linked_to', (site,qid)->
#     q = Docs.findOne 
#         model:'stack_question'
#         question_id:parseInt(qid)
#         site:site
#     Docs.find 
#         model:'stack_question'
#         linked_to_ids:$in:[q._id]
#         site:site

# Meteor.publish 'related_questions', (site,qid)->
#     q = Docs.findOne 
#         model:'stack_question'
#         question_id:parseInt(qid)
#         site:site
#     Docs.find 
#         model:'stack_question'
#         _id:$in:q.related_question_ids
#         site:q.site

# Meteor.publish 'linked_questions', (site,qid)->
#     q = Docs.findOne 
#         model:'stack_question'
#         question_id:parseInt(qid)
#         site:site
#     Docs.find 
#         model:'stack_question'
#         _id:$in:q.linked_question_ids
#         site:q.site
