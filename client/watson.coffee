Template.doc_emotion.onCreated ->
    # Meteor.setTimeout ->
    #     $('.progress').progress()
    # , 1000
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 1000

Template.small_sentiment.onCreated ->
    # Meteor.setTimeout ->
    #     $('.progress').progress()
    # , 1000

Template.small_sentiment.helpers
    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'


Template.doc_emotion.helpers
    # sadness_percent: -> (@sadness*100).toFixed()            
    # joy_percent: -> (@joy*100).toFixed()   
    # disgust_percent: -> (@disgust*100).toFixed()         
    # anger_percent: -> (@anger*100).toFixed()
    # fear_percent: -> (@fear*100).toFixed()


    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
            
        
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'
        
    is_positive: -> if @doc_sentiment_label is 'positive' then true else false    


Template.keywords.helpers
    relevance_percent: -> (@relevance*100).toFixed()

    sentiment_percent: -> 
        (@sentiment.score*100).toFixed()

    sadness_percent: -> (@sadness*100).toFixed()            
    # joy_percent: -> (@joy*100).toFixed()   
    disgust_percent: -> (@disgust*100).toFixed()         
    anger_percent: -> (@anger*100).toFixed()
    fear_percent: -> (@fear*100).toFixed()

Template.keywords.onRendered ->
    # Meteor.setTimeout ->
    #     $('.progress').progress()
    # , 2000
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 2000
    
    
Template.call_watson.events
    'click .autotag': -> 
        $('body').toast(
            position: 'bottom center',
            showIcon: 'refresh'
            message: 'autotagging'
            displayTime: 'auto',
        )
        # Meteor.call 'call_watson',Router.current().params.doc_id,'url','url',(err,res)=>
        Meteor.call 'call_watson',Router.current().params.doc_id,@key,@mode,(err,res)=>
            if err
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'alert'
                    message: 'error', err.error
                    displayTime: 'auto',
                    classProgress: 'purple'
                )
            else 
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'checkmark'
                    message: 'autotagged', res
                    displayTime: 'auto',
                    class:'success'
                    classProgress: 'blue'
                )

Template.get_emotion.events
    'click .get': -> 
        $('body').toast(
            position: 'bottom center',
            showIcon: 'refresh'
            message: 'getting emotion'
            displayTime: 'auto',
        )
        Meteor.call 'get_emotion',Router.current().params.doc_id,'body',(err,res)=>
            if err
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'question'
                    message: 'error getting emotion', err.error
                    displayTime: 'auto',
                )
            else 
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'checkmark'
                    message: 'emotion', res
                    displayTime: 'auto',
                )
Template.rpost.events
    'click .get_emotion': -> 
        $('body').toast(
            position: 'bottom center',
            showIcon: 'refresh'
            message: 'getting emotion'
            displayTime: 'auto',
        )
        Meteor.call 'get_emotion',Router.current().params.doc_id,'url',(err,res)=>
            if err
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'question'
                    message: 'error getting emotion', err.error
                    displayTime: 'auto',
                )
            else 
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'checkmark'
                    message: 'emotion', res
                    displayTime: 'auto',
                )

# Template.call_visual_analysis.events
#     'click #call_visual': ->
#         Meteor.call 'call_visual', Router.current().params.doc_id, ->

Template.call_tone.events
    'click .call': ->
        $('body').toast(
            position: 'bottom center',
            showIcon: 'smile'
            message: 'getting tone'
            displayTime: 'auto',
        )
        Meteor.call 'call_tone', Router.current().params.doc_id, (err,res)->
            $('body').toast(
                position: 'bottom center',
                showIcon: 'checkmark'
                message: 'tone', res
                displayTime: 'auto',
            )



Template.doc_sentiment.onRendered ->
    # Meteor.setTimeout ->
    #     $('.progress').progress()
    # , 2000


Template.doc_sentiment.helpers
    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
            
        
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'
        
    is_positive: -> if @doc_sentiment_label is 'positive' then true else false
    
    
Template.tone.helpers
    tone_label_class: () ->
        # console.log @
        # console.log @tones[0].tone_id
        # switch @tones[0].tone_id
        switch @tone_id
            when 'sadness' then 'blue inverted'
            when 'joy' then 'green inverted'
            when 'confident' then 'teal inverted'
            when 'analytical' then 'orange inverted'
            when 'tentative' then 'yellow inverted'

    tone_size: () ->
        # console.log 'this weight', @weight
        # console.log typeof parseFloat(@relevance)
        # console.log typeof (@relevance*100).toFixed()
        if @weight
            if @weight is -5 then 'f6'
            else if @weight is -4 then 'f7'
            else if @weight is -3 then 'f8'
            else if @weight is -2 then 'f9'
            else if @weight is -1 then 'f10'
            else if @weight is 0 then 'f12'
            else if @weight is 1 then 'f12'
            else if @weight is 2 then 'f13'
            else if @weight is 3 then 'f14'
            else if @weight is 4 then 'f15'
            else if @weight is 5 then 'f16'
        else
            'f11'