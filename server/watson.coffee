NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
# VisualRecognitionV3 = require('ibm-watson/visual-recognition/v3')
# TextToSpeechV1 = require('ibm-watson/text-to-speech/v1')
# ToneAnalyzerV3 = require('ibm-watson/tone-analyzer/v3')

{ IamAuthenticator } = require('ibm-watson/auth')



# textToSpeech = new TextToSpeechV1({
#   authenticator: new IamAuthenticator({
#     apikey: Meteor.settings.private.tts.apikey,
#   }),
#   url: Meteor.settings.private.tts.url,
# });



natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2019-07-12'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.language.apikey
    })
    url: Meteor.settings.private.language.url)

# const classify_params = {
#   url: 'https://ibm.biz/BdzLPG',
# };
Meteor.methods
    call_watson: (doc_id, key, mode) ->
        self = @
        @unblock()
        doc = Docs.findOne doc_id
        # console.log 'calling watson', doc_id, key, mode
        # if doc.skip_watson is false
        # else
        # unless doc.watson
        params =
            # url: doc.url
            returnAnalyzedText: true
            clean: true
            concepts:
                limit:30
            features:
                entities:
                    emotion: true
                    sentiment: true
                    mentions: true
                    limit: 30
                keywords:
                    emotion: true
                    sentiment: true
                    limit: 30
                concepts: {}
                categories:
                    explanation:true
                emotion:{}
                # relations: {}
                # semantic_roles: {}
                sentiment: {}
        if mode is 'html'
            params.html = doc["#{key}"]
            params.returnAnalyzedText = true
            # params.html = doc.data.description

        else if doc.url
            params.features.metadata = {}
            params.url = doc.url
        natural_language_understanding.analyze params, Meteor.bindEnvironment((err, response)=>
            if err
                # if err.code is 400
                    # unless err.code is 403
                    #     Docs.update doc_id,
                    #         $set:skip_watson:false
                throw new Meteor.Error(err.statusText,err.body)
                # return err
            else
                
                response = response.result
                # if Meteor.isDevelopment
                # emotions = response.emotion.document.emotion

                adding_tags = []
                if response.categories
                    for categories in response.categories
                        for category in categories.label.split('/')
                            if category.length > 0
                                # adding_tags.push category
                                Docs.update doc_id,
                                    $addToSet:
                                        categories: category
                                        # tags: category
                # Docs.update { _id: doc_id },
                #     $addToSet:
                #         tags:$each:adding_tags
                if response.entities and response.entities.length > 0
                    for entity in response.entities
                        unless entity.type is 'Quantity'
                            # if Meteor.isDevelopment
                            # else
                            Docs.update { _id: doc_id },
                                $addToSet:
                                    "#{entity.type}":entity.text
                                    tags:entity.text.toLowerCase()
                emotions = response.emotion.document.emotion

                emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
                # main_emotions = []
                max_emotion_percent = 0
                max_emotion_name = ''

                for emotion in emotion_list
                    if emotions["#{emotion}"] > max_emotion_percent
                        if emotions["#{emotion}"] > .5
                            max_emotion_percent = emotions["#{emotion}"]
                            max_emotion_name = emotion
                            # main_emotions.push emotion
                sadness_percent = emotions.sadness
                joy_percent = emotions.joy
                fear_percent = emotions.fear
                anger_percent = emotions.anger
                disgust_percent = emotions.disgust
                                    
                concept_array = _.pluck(response.concepts, 'text')
                lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                keyword_array = _.pluck(response.keywords, 'text')
                lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()

                keywords_concepts = lowered_keywords.concat lowered_keywords
                # Docs.update { _id: doc_id },
                #     $addToSet:
                #         tags:$each:lowered_concepts
                # console.log response
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:keywords_concepts
                    $set:
                        analyzed_text:response.analyzed_text
                        metadata:response.metadata
                        watson:true
                        sentiment:response.sentiment
                        watson_concepts: concept_array
                        watson_keywords: keyword_array
                        doc_sentiment_score: response.sentiment.document.score
                        doc_sentiment_label: response.sentiment.document.label
                        max_emotion_name:max_emotion_name
                        max_emotion_percent:max_emotion_percent
                        sadness_percent: sadness_percent
                        joy_percent: joy_percent
                        fear_percent: fear_percent
                        anger_percent: anger_percent
                        disgust_percent: disgust_percent

                        
                final_doc = Docs.findOne doc_id

                # if mode is 'url'
                #     Meteor.call 'call_tone', doc_id, 'body', 'text', ->

                # Meteor.call 'log_doc_terms', doc_id, ->
                Meteor.call 'clear_blocklist_doc', doc_id, ->
                # if Meteor.isDevelopment
        )
        return doc_id