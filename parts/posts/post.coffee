# if Meteor.isClient
    # Template.post_card.onRendered ->
#     # console.log @
#     Meteor.call 'log_view', @data._id, ->
#     # Session.set('session_clicks', Session.get('session_clicks')+2)



# Template.post_card.helpers
#     card_class: ->
#         if Meteor.userId()
#             if @viewer_ids 
#                 if Meteor.userId() in @viewer_ids
#                     'link'
#                 else
#                     'raised link'
#             else
#                 'raised link'
#         else
#             'raised link'
