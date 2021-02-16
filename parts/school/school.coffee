# if Meteor.isClient
#     Router.route '/school/', (->
#         @layout 'layout'
#         @render 'school'
#         ), name:'school'
    

#     Template.school.onCreated ->
#         @autorun => Meteor.subscribe 'model_docs', 'course'
#         @autorun => Meteor.subscribe 'model_docs', 'income'
        
#     Template.school.helpers
#         school_total: ->
#             course_total = 0
#             courses = 
#                 Docs.find 
#                     model:'course'
#             for course in courses.fetch()
#                 course_total += course.amount
#             income_total = 0
#             incomes = 
#                 Docs.find 
#                     model:'income'
#             for income in incomes.fetch()
#                 income_total += income.amount
            
#             income_total - course_total 
            
            
#         courses: ->
#             Docs.find
#                 model:'course'
#         income: ->
#             Docs.find
#                 model:'income'
        
#         course: -> Session.equals('course', @_id)
#         editing_income: -> Session.equals('editing_income', @_id)
        
        
#     Template.school.events
#         'click .recalc_school_stats': ->
#             Meteor.call 'calc_school_stats', ->
                
#         'click .course': ->
#             Session.set('course',null)
#         'click .save_income': ->
#             Session.set('editing_income',null)
#         'click .course': ->
#             Session.set('course',@_id)
#         'click .edit_income': ->
#             Session.set('editing_income',@_id)
#         'click .course': ->
#             new_id = 
#                 Docs.insert 
#                     model:'course'
#             Session.set('course',new_id)

#         'click .add_income': ->
#             new_id = 
#                 Docs.insert 
#                     model:'income'
#             Session.set('editing_income',new_id)

#     # Template.course_stats.onCreated ->
#     #     @autorun => Meteor.subscribe 'model_docs', 'school_stat'
        
#     # Template.course_stats.helpers
#     #     fs: ->
#     #         Docs.findOne model:'school_stat'
#     # Template.course_stats.events
#     #     'click .recalc_school_stats': ->
#     #         Meteor.call 'calc_school_stats', ->
                



# if Meteor.isServer
#     # Meteor.publish 'product_from_debit_id', (debit_id)->
#     #     debit = Docs.findOne debit_id
#     #     Docs.find 
#     #         _id:debit.product_id
            
#     Meteor.methods
#         calc_school_stats: ()->
#             fs = Docs.findOne model:'school_stat'
#             unless fs 
#                 Docs.insert 
#                     model:'school_stat'
#             fs = Docs.findOne model:'school_stat'
            
#             course_sum = 0
            
#             courses = 
#                 Docs.find 
#                     model:'course'
#             for course in courses.fetch()
#                 course_sum += course.dollar_amount
        
#             total_membership_sum = 0
#             memberships = 
#                 Docs.find 
#                     model:'course'
#                     membership:true
#             for membership in memberships.fetch()
#                 total_membership_sum += membership.dollar_amount
        
#             console.log 'total courses', course_sum
#             Docs.update fs._id,
#                 $set:
#                     course_sum:course_sum
#                     course_count:courses.count()
#                     membership_count:memberships.count()
#                     total_membership_sum:total_membership_sum