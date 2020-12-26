# if Meteor.isClient
#     # Template.emotion_pick.events
#     #     'click .pick': ->
#     #         Docs.update Template.parentData()._id,
#     #             $set:
#     #                 emotion:@k

#     # Template.emotion_pick.helpers
#     #     pick_class: ->
#     #         if Template.parentData().emotion is @k then @color else 'grey'

#     Template.print_this.events
#         'click .print_this': -> console.log @
#     Template.smart_tagger.onCreated ->
#         # @autorun => @subscribe 'tag_results',
#         #     # @_id
#         #     selected_tags.array()
#         #     Session.get('searching')
#         #     Session.get('current_query')
#         #     Session.get('dummy')

#     Template.smart_tagger.helpers        
#         # terms: -> Terms.find()
#         # suggestions: -> Tag_results.find()

#     Template.smart_tagger.events
#         'keyup .new_tag': _.throttle((e,t)->
#             query = $('.new_tag').val()
#             if query.length > 0
#                 Session.set('searching', true)
#             else
#                 Session.set('searching', false)
#             Session.set('current_query', query)
            
#             if e.which is 13
#                 element_val = t.$('.new_tag').val().toLowerCase().trim()
#                 Docs.update @_id,
#                     $addToSet:tags:element_val
#                 selected_tags.push element_val
#                 # Meteor.call 'log_term', element_val, ->
#                 Session.set('searching', false)
#                 Session.set('current_query', '')
#                 Meteor.call 'add_tag', @_id, ->
    
#                 # Session.set('dummy', !Session.get('dummy'))
#                 t.$('.new_tag').val('')
#         , 250)

#         'click .remove_element': (e,t)->
#             element = @vOf()
#             field = Template.currentData()
#             selected_tags.remove element
#             Docs.update @_id,
#                 $pull:tags:element
#             t.$('.new_tag').focus()
#             t.$('.new_tag').val(element)
#             # Session.set('dummy', !Session.get('dummy'))
    
    
#         'click .select_term': (e,t)->
#             # selected_tags.push @title
#             Docs.update @_id,
#                 $addToSet:tags:@title
#             selected_tags.push @title
#             $('.new_tag').val('')
#             Session.set('current_query', '')
#             Session.set('searching', false)
#             # Session.set('dummy', !Session.get('dummy'))



#     Template.session_toggle_button.helpers
#         session_toggle_button_class: ->
#             if Template.instance().subscriptionsReady()
#                 if Session.get(@k) then 'grey' else 'basic'
#             else
#                 'disabled loading'
#     Template.session_toggle_button.events
#         'click .toggle': -> Session.set(@k, !Session.get(@k))


#     Template.remove_button.events
#         'click .remove_doc': (e,t)->
#             Meteor.call 'remove_doc', @_id
#             # if confirm 'delete'
#             #     # Docs.remove @_id


#     Template.remove_icon.events
#         'click .remove_doc': (e,t)->
#             $('body').toast
#                 message: "confirm delete #{@title}?"
#                 displayTime: 0
#                 class: 'black'
#                 actions: [
#                     {
#                         text: 'yes'
#                         icon: 'remove'
#                         class: 'red'
#                         click: ->
#                             Docs.remove @_id
#                             $('body').toast message: 'deleted'
#                     }
#                     {
#                         icon: 'ban'
#                         text: 'cancel'
#                         class: 'icon yellow'
#                     }
#                 ]
            
#             # if confirm "remove #{@model}?"
#             #     if $(e.currentTarget).closest('.card')
#             #         $(e.currentTarget).closest('.card').transition('fly right', 1000)
#             #     else
#             #         $(e.currentTarget).closest('.segment').transition('fly right', 1000)
#             #         $(e.currentTarget).closest('.item').transition('fly right', 1000)
#             #         $(e.currentTarget).closest('.content').transition('fly right', 1000)
#             #         $(e.currentTarget).closest('tr').transition('fly right', 1000)
#             #         $(e.currentTarget).closest('.event').transition('fly right', 1000)
#             #     Meteor.setTimeout =>
#             #         Docs.remove @_id
#             #     , 1000

#     Template.kve.events
#         'click .set_key_v': ->
#             p = Template.parentData()
#             # parent = Docs.findOne @_id
#             Docs.update p._id,
#                 $set: "#{@k}": @v

#     Template.kve.helpers
#         set_kv_class: ->
#             # parent = Docs.findOne @_id
#             p = Template.parentData()
#             if p["#{@k}"] is @v then 'active' else 'basic'
    


#     Template.skve.events
#         'click .set_session_v': ->
#             if Session.equals(@k,@v)
#                 Session.set(@k, null)
#             else
#                 Session.set(@k, @v)

#     Template.skve.helpers
#         calculated_class: ->
#             res = ''
#             if @classes
#                 res += @classes
#             if Session.get(@k)
#                 if Session.equals(@k,@v)
#                     res += ' large compact active'
#                 else
#                     # res += ' compact displaynone'
#                     res += ' compact basic '
#                 res
#             else
#                 'basic '
#         selected: -> Session.equals(@k,@v)



#     Template.sbt.events
#         'click .toggle_session_key': ->
#             Session.set(@k, !Session.get(@k))

#     Template.sbt.helpers
#         calculated_class: ->
#             res = ''
#             if @classes
#                 res += @classes
#             if Session.get(@k)
#                 res += ' black'
#             else
#                 res += ' basic'

#             res
