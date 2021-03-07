if Meteor.isClient
    Template.unpick_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
    Template.unpick_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.unpick_tag.events
        'click .unpick':-> 
            picked_tags.remove @valueOf()
            Meteor.call 'search_reddit', picked_tags.array(), ->
            url = new URL(window.location);
            url.searchParams.set('tags', picked_tags.array());
            window.history.pushState({}, '', url);
            document.title = picked_tags.array()
            Meteor.call 'call_alpha', picked_tags.array().toString(), ->
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 7000
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
    

    
