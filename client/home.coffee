@picked_tags = new ReactiveArray []

Template.home.onCreated ->
    @autorun => Meteor.subscribe 'tags',
        picked_tags.array()
    @autorun => Meteor.subscribe 'count', 
        picked_tags.array()
    @autorun => Meteor.subscribe 'posts', 
        picked_tags.array()

Template.home.helpers
    posts: ->
        Docs.find({
            model: 'rpost'
        },
            sort: ups:-1
            limit:10
        )
  
    counter: -> Counts.get 'counter'

    picked_tags: -> picked_tags.array()
  
    result_tags: -> results.find(model:'tag')
   
        
Template.home.events
    'keyup .search_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_tag').val().trim().toLowerCase()
            window.speechSynthesis.speak new SpeechSynthesisUtterance val
            picked_tags.push val   
            t.$('.search_tag').val('')
            # Session.set('sub_doc_query', val)
            Session.set('loading',true)
    
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
        

    'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
    'click .set_list': (e,t)-> Session.set('view_layout', 'list')
 
 
 
 
Template.post_card_small.events
    'click .view_post': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
 
Template.post_card_small.helpers
    five_tags: -> @tags[..5]
 
Template.tag_picker.events
    'click .pick_tag': -> 
        picked_tags.push @name.toLowerCase()
        $('.search_tag').val('')
        Session.set('skip_value',0)

        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        
        

Template.unpick_tag.events
    'click .unpick_tag': -> 
        Session.set('skip',0)
        # console.log @
        picked_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)


Template.flat_tag_picker.events
    'click .pick_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        picked_tags.push @valueOf()
        $('.search_home').val('')
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array()
