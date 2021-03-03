# @picked_tags = new ReactiveArray []
# @picked_times = new ReactiveArray []
# @picked_locations = new ReactiveArray []
# @picked_authors = new ReactiveArray []

# Router.route '/p/:doc_id/edit', (->
#     @layout 'layout'
#     @render 'post_edit'
#     ), name:'post_edit'


# Template.nav.onCreated ->
#     # Session.setDefault('session_clicks', 0)
# Template.home.onCreated ->
#     Session.setDefault('sort_key', '_timestamp')
#     Session.setDefault('sort_direction', -1)
#     # Session.setDefault('location_query', null)
#     @autorun => Meteor.subscribe 'dao_tags',
#         picked_tags.array()
#         # picked_times.array()
#         # picked_locations.array()
#         # picked_authors.array()
#     @autorun => Meteor.subscribe 'post_count', 
#         picked_tags.array()
#         # picked_times.array()
#         # picked_locations.array()
#         # picked_authors.array()
#     @autorun => Meteor.subscribe 'posts', 
#         picked_tags.array()
#         # picked_times.array()
#         # picked_locations.array()
#         # picked_authors.array()
#         # Session.get('sort_key')
#         # Session.get('sort_direction')
#         # Session.get('skip_value')



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
# Template.home.helpers
#     posts: ->
#         Docs.find {
#             model:$in:['post','rpost']
#         }, sort: _timestamp:-1
       
#     picked_tags: -> picked_tags.array()
#     picked_locations: -> picked_locations.array()
#     picked_authors: -> picked_authors.array()
#     picked_times: -> picked_times.array()
#     post_counter: -> Counts.get 'post_counter'
    
#     result_tags: -> results.find(model:'tag')
#     author_results: -> results.find(model:'author')
#     location_results: -> results.find(model:'location_tag')
#     time_results: -> results.find(model:'time_tag')
        
#     sidebar_class: -> if Session.get('view_sidebar') then 'ui four wide column' else 'hidden'
#     main_column_class: -> if Session.get('view_sidebar') then 'ui twelve wide column' else 'ui sixteen wide column' 
        
# Template.rpost_card.events
#     'click .get_post': ->
#         Meteor.call 'get_reddit_post', @_id, ->
# Template.user_post_small.events
#     'click .mark_viewed': (e,t)->
#         Meteor.call 'log_view', @_id, ->
#         if Meteor.userId()
#             Docs.update @_id,
#                 $addToSet:viewer_ids:Meteor.userId()
#         Meteor.users.update @_author_id,
#             $inc:points:1
# Template.home.events
#     'click .enable_sidebar': (e,t)-> Session.set('view_sidebar',true)
#     'click .disable_sidebar': (e,t)-> Session.set('view_sidebar',false)
#     'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
#     'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
#     'click .sort_up': (e,t)-> Session.set('sort_direction',1)

#     'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
#     'click .set_list': (e,t)-> Session.set('view_layout', 'list')


#     'click .mark_viewed': (e,t)->
#         if Meteor.userId()
#             Docs.update @_id,
#                 $addToSet:viewer_ids:Meteor.userId()
#             Meteor.users.update @_author_id,
#                 $inc:points:1
#     'keyup .search_tag': (e,t)->
#          if e.which is 13
#             val = t.$('.search_tag').val().trim().toLowerCase()
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance val
#             $('.search_tag').transition('pulse')
#             $('.black').transition('pulse')
#             $('.seg .pick_tag').transition({
#                 animation : 'pulse',
#                 duration  : 500,
#                 interval  : 300
#             })
#             $('.seg .black').transition({
#                 animation : 'pulse',
#                 duration  : 500,
#                 interval  : 300
#             })
#             # $('.pick_tag').transition('pulse')
#             # $('.card_small').transition('shake')
#             $('.pushed .card_small').transition({
#                 animation : 'pulse',
#                 duration  : 500,
#                 interval  : 300
#             })
#             picked_tags.push val   
#             t.$('.search_tag').val('')
#             # Session.set('sub_doc_query', val)
#             Meteor.call 'search_reddit', picked_tags.array(), ->
#                 Session.set('loading',false)
#             Meteor.setTimeout ->
#                 Session.set('toggle',!Session.get('toggle'))
#             , 5000



#     'click .make_private': ->
#         # if confirm 'make private?'
#         Docs.update @_id,
#             $set:is_private:true

#     'click .upvote': ->
#         Docs.update @_id,
#             $inc:points:1
#     'click .downvote': ->
#         Docs.update @_id,
#             $inc:points:-1
#     'keyup .add_tag': (e,t)->
#         if e.which is 13
#             new_tag = $(e.currentTarget).closest('.add_tag').val().toLowerCase().trim()
#             Docs.update @_id,
#                 $addToSet: tags:new_tag
#             $(e.currentTarget).closest('.add_tag').val('')
            
            
#     'click .unpick_time': ->
#         picked_times.remove @valueOf()
#     'click .pick_time': ->
#         picked_times.push @name
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .pick_flat_time': ->
#         picked_times.push @valueOf()
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .unpick_location': ->
#         picked_locations.remove @valueOf()
#     'click .pick_location': ->
#         picked_locations.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .unpick_author': ->
#         picked_authors.remove @valueOf()
#     'click .pick_author': ->
#         picked_authors.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name

#     'click .unpick_Location': ->
#         picked_Locations.remove @valueOf()
#     'click .pick_Location': ->
#         picked_Locations.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .unpick_time_tag': ->
#         group_picked_time_tags.remove @valueOf()
#     'click .pick_time_tag': ->
#         group_picked_time_tags.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
        
#     'click .unpick_timestamp_tag': ->
#         group_picked_timestamp_tags.remove @valueOf()
#     'click .pick_timestamp_tag': ->
#         group_picked_timestamp_tags.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .unpick_location_tag': ->
#         group_picked_location_tags.remove @valueOf()
#     'click .pick_location_tag': ->
#         group_picked_location_tags.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
  
#     'click .unpick_author': ->
#         group_picked_author_tags.remove @valueOf()
#     'click .pick_author': ->
#         group_picked_author_tags.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    
     
#     'keyup .search_love_tag': (e,t)->
#          if e.which is 13
#             val = t.$('.search_love_tag').val().trim().toLowerCase()
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance val
#             picked_tags.push val   
#             t.$('.search_love_tag').val('')
            
            
#     Template.tag_picker.onCreated ->
#         # @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
#     Template.tag_picker.helpers
#         picker_class: ()->
#             term = 
#                 Docs.findOne 
#                     title:@name.toLowerCase()
#             if term
#                 if term.max_emotion_name
#                     switch term.max_emotion_name
#                         when 'joy' then " basic green"
#                         when "anger" then " basic red"
#                         when "sadness" then " basic blue"
#                         when "disgust" then " basic orange"
#                         when "fear" then " basic grey"
#                         else "basic grey"
#         term: ->
#             res = 
#                 Docs.findOne 
#                     title:@name.toLowerCase()
#             # console.log res
#             res
                
#     Template.tag_picker.events
#         'click .pick_tag': -> 
#             # results.update
#             # console.log @
#             # window.speechSynthesis.cancel()
#             window.speechSynthesis.speak new SpeechSynthesisUtterance @name
#             # if @model is 'love_emotion'
#             #     picked_emotions.push @name
#             # else
#             # if @model is 'love_tag'
#             picked_tags.push @name
#             # $('.search_sublove').val('')
#             # Session.set('skip_value',0)
    
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
#             # Session.set('love_loading',true)
#             Meteor.call 'search_reddit', picked_tags.array(), ->
#                 Session.set('loading',false)
#                 # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array()
#             Meteor.setTimeout ->
#                 Session.set('toggle',!Session.get('toggle'))
#             , 5000

            
            
    
#     Template.unpick_tag.onCreated ->
#         # @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
#     Template.unpick_tag.helpers
#         term: ->
#             found = 
#                 Docs.findOne 
#                     # model:'wikipedia'
#                     title:@valueOf().toLowerCase()
#             found
#     Template.unpick_tag.events
#         'click .unpick_tag': -> 
#             Session.set('skip',0)
#             # console.log @
#             picked_tags.remove @valueOf()
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
    
#     Template.flat_tag_picker.onCreated ->
#         # @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
#     Template.flat_tag_picker.helpers
#         picker_class: ()->
#             term = 
#                 Docs.findOne 
#                     title:@valueOf().toLowerCase()
#             if term
#                 if term.max_emotion_name
#                     switch term.max_emotion_name
#                         when 'joy' then " basic green"
#                         when "anger" then " basic red"
#                         when "sadness" then " basic blue"
#                         when "disgust" then " basic orange"
#                         when "fear" then " basic grey"
#                         else "basic grey"
#         term: ->
#             Docs.findOne 
#                 title:@valueOf().toLowerCase()
#     Template.flat_tag_picker.events
#         'click .pick_flat_tag': -> 
#             # results.update
#             # window.speechSynthesis.cancel()
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
#             picked_tags.push @valueOf()
#             $('.search_tags').val('')
