Template.registerHelper 'is_positive', () ->
    # console.log @doc_sentiment_score
    if @doc_sentiment_score
        @doc_sentiment_score > 0
    
Template.registerHelper 'sentiment_class', () ->
    if @sentiment_avg > 0 then 'green' else 'red'
Template.registerHelper 'sv', (key) -> Session.get(key)
Template.registerHelper 'sentence_color', () ->
    switch @tones[0].tone_id
        when 'sadness' then 'blue'
        when 'joy' then 'green'
        when 'confident' then 'teal'
        when 'analytical' then 'orange'
        when 'tentative' then 'yellow'

Template.registerHelper 'calculated_size', (metric) ->
    # whole = parseInt(@["#{metric}"]*10)
    whole = parseInt(metric*10)
    switch whole
        when 0 then 'f5'
        when 1 then 'f6'
        when 2 then 'f7'
        when 3 then 'f8'
        when 4 then 'f9'
        when 5 then 'f10'
        when 6 then 'f11'
        when 7 then 'f12'
        when 8 then 'f13'
        when 9 then 'f14'
        when 10 then 'f15'
    
Template.registerHelper 'abs_percent', (num) -> 
    # console.l/og Math.abs(num*100)
    parseInt(Math.abs(num*100))



Template.doc_emotion.onCreated ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 1000
    Meteor.setTimeout ->
        $('.ui.accordion').accordion()
    , 1000

Template.small_sentiment.onCreated ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 1000

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
    Meteor.setTimeout ->
        $('.progress').progress()
    , 2000
    Meteor.setTimeout ->
        $('.ui.accordion').accordion()
    , 2000
    

# Template.call_visual_analysis.events
#     'click #call_visual': ->
#         Meteor.call 'call_visual', Router.current().params.doc_id, ->

# Template.tone.events
#     'click #call_tone': ->
#         Meteor.call 'call_tone', Router.current().params.doc_id, ->



Template.doc_sentiment.onRendered ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 2000


Template.doc_sentiment.helpers
    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
            
        
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'
        
    is_positive: -> if @doc_sentiment_label is 'positive' then true else false