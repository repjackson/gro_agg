Template.reddit_doc.onRendered ->
    # Meteor.setTimeout( =>
    #     # console.log @
    #     $('.ui.embed').embed({
    #         source: 'youtube',
    #         # url: @data.url
    #         # placeholder: '/images/bear-waving.jpg'
    #     });
    # , 1000)
Template.reddit_doc.onRendered ->
    # console.log @data
    # unless @data.watson
    #     # console.log 'call'
    #     Meteor.call 'call_watson', @data._id, 'url','url',->
    # if @data.response
    # window.speechSynthesis.cancel()
    # Meteor.setTimeout =>
    #     if @data.title
    #         window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    # , 1000
Template.reddit_doc.onRendered ->
    # console.log @data
    unless @data.watson
        # console.log 'call'
        Meteor.call 'call_watson', @data._id, 'url','url',->
    if @data.watson
        unless @data.tone
            # console.log 'call'
            Meteor.call 'call_tone', @data._id,->
    Meteor.call 'uniq', @data._id, ->
    unless @data.points
        # console.log 'no points'
        Docs.update @data._id,
            $set:points:0
    if @data.rd and @data.rd.selftext_html
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = @data.rd.selftext_html
        # console.log 'innner html', dom.value
        # return dom.value
        Docs.update @data._id,
            $set:
                parsed_selftext_html:dom.value
            
    # else 
    #     console.log 'points'
    


        


Template.reddit_doc.helpers
    viewing_doc: -> Session.equals('viewing_doc', @_id)
    card_class: -> if Session.equals('viewing_doc', @_id) then 'fluid'


Template.reddit_doc.events
    'click .toggle_view': (e,t)-> 
        if Session.equals('viewing_doc', @_id)
            Session.set('viewing_doc', null)
            # window.speechSynthesis.cancel()
        else
            window.speechSynthesis.cancel()
            Session.set('viewing_doc', @_id)
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title
            if @tone 
                for sentence in @tone.result.sentences_tone
                    # console.log sentence
                    Session.set('current_reading_sentence',sentence)
                    window.speechSynthesis.speak new SpeechSynthesisUtterance sentence.text
    'click .read': (e,t)-> 
        if @tone 
            window.speechSynthesis.cancel()
            for sentence in @tone.result.sentences_tone
                # console.log sentence
                Session.set('current_reading_sentence',sentence)
                window.speechSynthesis.speak new SpeechSynthesisUtterance sentence.text
    'click .print_me': (e,t)-> console.log @
    # 'click .tagger': (e,t)->
    #     Meteor.call 'call_watson', @_id, 'url', 'url', ->
    'keyup .tag_post': (e,t)->
        # console.log 
        if e.which is 13
            # $(e.currentTarget).closest('.button')
            tag = $(e.currentTarget).closest('.tag_post').val().toLowerCase().trim()
            # console.log tag
            # console.log @
            Docs.update @_id,
                $addToSet: tags: tag
            $(e.currentTarget).closest('.tag_post').val('')
            # console.log tag
    'click .add_tag': -> 
        # console.log @valueOf()
        selected_tags.push @valueOf()
        # # if Meteor.user()
        Session.set('viewing_doc',null)

        Meteor.call 'call_wiki', @valueOf(), ->
        Meteor.call 'search_reddit', selected_tags.array(), ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()

    # 'click .delete': -> 
    #     console.log @
    #     Docs.remove @_id
    'click .vote_up': -> 
        Docs.update @_id,
            $inc: points: 1
        # window.speechSynthesis.cancel()# 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'yeah'
    'click .vote_down': -> 
        Docs.update @_id,
            $inc: points: -1
            # window.speechSynthesis.cancel()# 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'ouch'
