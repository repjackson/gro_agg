# if Meteor.isClient
#     Router.route '/ruser/:user_id', (->
#         @layout 'layout'
#         @render 'ruser'
#         ), name:'ruser'

#     Template.ruser.onCreated ->
#         @autorun => Meteor.subscribe 'ruser_doc', Router.current().params.subreddit, Router.current().params.user_id
#         # @autorun => Meteor.subscribe 'ruser_badges', Router.current().params.subreddit, Router.current().params.user_id
#         # @autorun => Meteor.subscribe 'ruser_tags', Router.current().params.subreddit, Router.current().params.user_id
#         @autorun => Meteor.subscribe 'ruser_comments', Router.current().params.subreddit, Router.current().params.user_id
#         @autorun => Meteor.subscribe 'ruser_questions', Router.current().params.subreddit, Router.current().params.user_id
#         @autorun => Meteor.subscribe 'ruser_answers', Router.current().params.subreddit, Router.current().params.user_id
#     Template.ruser.onRendered ->
#         Meteor.call 'search_ruser', Router.current().params.subreddit, Router.current().params.user_id, ->

#         # Meteor.call 'ruser_answers', Router.current().params.subreddit, Router.current().params.user_id, ->
#         Meteor.call 'ruser_questions', Router.current().params.subreddit, Router.current().params.user_id, ->
#         Meteor.call 'ruser_tags', Router.current().params.subreddit, Router.current().params.user_id, ->
#         # Meteor.call 'ruser_comments', Router.current().params.subreddit, Router.current().params.user_id, ->
#         # Meteor.call 'ruser_badges', Router.current().params.subreddit, Router.current().params.user_id, ->
#         Meteor.setTimeout ->
#             Meteor.call 'omega', Router.current().params.subreddit, Router.current().params.user_id, ->
#         , 1000

#     Template.user_question_item.onRendered ->
#         unless @data.watson
#             Meteor.call 'call_watson', @data._id,'link','stack',->
        
        
#     Template.ruser.helpers
#         ruser_doc: ->
#             Docs.findOne 
#                 model:'ruser'
#                 subreddit:Router.current().params.subreddit
#                 user_id:parseInt(Router.current().params.user_id)
#         user_comments: ->
#             Docs.find
#                 model:'stack_comment'
#                 user_id:parseInt(Router.current().params.user_id)
#                 subreddit:Router.current().params.subreddit
#         user_questions: ->
#             Docs.find
#                 model:'stack_question'
#                 subreddit:Router.current().params.subreddit
#                 "owner.user_id":parseInt(Router.current().params.user_id)
#         user_answers: ->
#             Docs.find
#                 model:'stack_answer'
#                 "owner.user_id":parseInt(Router.current().params.user_id)
#         # user_badges: ->
#         #     Docs.find
#         #         model:'stack_badge'
#         # user_tags: ->
#         #     Docs.find
#         #         model:'stack_tag'

#     Template.answer_item.onCreated ->
#         @autorun => Meteor.subscribe 'question_from_id', @data.question_id
        
#     Template.answer_item.helpers
#         answer_question: ->
#             Docs.findOne
#                 model:'stack_question'
#                 question_id:@question_id
    
#     Template.ruser.events
#         'click .set_location': ->
#             Session.set('location_query',@location)
#             window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.subreddit} users in #{@location}"
#             Router.go "/s/#{Router.current().params.subreddit}/users"

#         'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
#         'click .toggle_question_detail': (e,t)-> Session.set('view_question_detail',!Session.get('view_question_detail'))

#         'click .boop': ->
#             window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
#             Meteor.call 'omega', Router.current().params.subreddit, Router.current().params.user_id, ->
#             Meteor.call 'rank_user', Router.current().params.subreddit, Router.current().params.user_id, ->
#             # Meteor.call 'boop', Router.current().params.subreddit, Router.current().params.user_id, ->
#         'click .agg': ->
#             Meteor.call 'omega', Router.current().params.subreddit, Router.current().params.user_id, ->
        
#         'click .say_subreddit': (e,t)->
#             window.speechSynthesis.speak new SpeechSynthesisUtterance Router.current().params.subreddit
#         'click .say_users': (e,t)->
#             window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.subreddit} users"
#         'click .say_questions': (e,t)->
#             window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.subreddit} questions"
#         'click .say_title': (e,t)->
#             window.speechSynthesis.speak new SpeechSynthesisUtterance @title

#         'click .search': ->
#             window.speechSynthesis.speak new SpeechSynthesisUtterance "import #{Router.current().params.subreddit} user"
#             Meteor.call 'search_ruser', Router.current().params.subreddit, Router.current().params.user_id, ->
#         'click .get_answers': ->
#             Meteor.call 'ruser_answers', Router.current().params.subreddit, Router.current().params.user_id, ->
#         'click .get_questions': ->
#             Meteor.call 'ruser_questions', Router.current().params.subreddit, Router.current().params.user_id, ->
#         'click .get_comments': ->
#             Meteor.call 'ruser_comments', Router.current().params.subreddit, Router.current().params.user_id, ->
#         'click .get_badges': ->
#             Meteor.call 'ruser_badges', Router.current().params.subreddit, Router.current().params.user_id, ->
#         'click .get_tags': ->
#             Meteor.call 'ruser_tags', Router.current().params.subreddit, Router.current().params.user_id, ->
                
        

    
# # if Meteor.isServer
# #     Meteor.publish 'question_from_id', (qid)->
# #         Docs.find 
# #             # model:'stack_question'
# #             question_id:qid
    
# #     Meteor.publish 'ruser_badges', (subreddit,user_id)->
# #         Docs.find { 
# #             model:'stack_badge'
# #             "user.user_id":parseInt(user_id)
# #         }, limit:10
# #     Meteor.publish 'ruser_comments', (subreddit,user_id)->
# #         Docs.find { 
# #             model:'stack_comment'
# #             "owner.user_id":parseInt(user_id)
# #         }, limit:10
# #     Meteor.publish 'ruser_questions', (subreddit,user_id)->
# #         Docs.find { 
# #             model:'stack_question'
# #             "owner.user_id":parseInt(user_id)
# #         }, limit:10
# #     Meteor.publish 'ruser_answers', (subreddit,user_id)->
# #         Docs.find { 
# #             model:'stack_answer'
# #             "owner.user_id":parseInt(user_id)
# #         }, limit:10
# #     Meteor.publish 'ruser_tags', (subreddit,user_id)->
# #         Docs.find { 
# #             model:'stack_tag'
# #             user_id:parseInt(user_id)
# #         }, limit:10
            
            
            