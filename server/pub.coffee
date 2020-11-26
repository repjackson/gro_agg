# Meteor.publish 'model_count', (
#     model
#     )->
#     match = {model:model}
    
#     Counts.publish this, 'model_counter', Docs.find(match)
#     return undefined

Meteor.publish 'question_from_id', (site,qid)->
    Docs.find 
        model:'stack_question'
        site:site
        question_id:parseInt(qid)

Meteor.publish 'suser_b', (site,user_id)->
    Docs.find { 
        model:'stack_badge'
        site:site
        "user.user_id":parseInt(user_id)
    }, limit:10
Meteor.publish 'suser_c', (site,user_id)->
    Docs.find { 
        model:'stack_comment'
        site:site
        "owner.user_id":parseInt(user_id)
    }, limit:100
Meteor.publish 'suser_q', (site,user_id)->
    # console.log 'looking ', site, user_id
    Docs.find { 
        model:'stack_question'
        site:site
        "owner.user_id":parseInt(user_id)
    }, limit:42
Meteor.publish 'suser_a', (site,user_id)->
    Docs.find { 
        model:'stack_answer'
        "owner.user_id":parseInt(user_id)
        site:site
    }, limit:10
Meteor.publish 'suser_t', (site,user_id)->
    Docs.find { 
        model:'stack_tag'
        site:site
        "owner.user_id":parseInt(user_id)
    }, limit:10
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
