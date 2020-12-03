NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
ToneAnalyzerV3 = require('ibm-watson/tone-analyzer/v3')
VisualRecognitionV3 = require('ibm-watson/visual-recognition/v3')
# PersonalityInsightsV3 = require('ibm-watson/personality-insights/v3')
# TextToSpeechV1 = require('ibm-watson/text-to-speech/v1')

{ IamAuthenticator } = require('ibm-watson/auth')

natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2020-08-01',
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.language.apikey
    })
    url: Meteor.settings.private.language.url)
# lang
# mkdgRJwYEJnuJUhCv0Ny7REL4scA27el5mdPKrnGMEMg
# textToSpeech = new TextToSpeechV1({
#   authenticator: new IamAuthenticator({
#     apikey: Meteor.settings.private.tts.apikey,
#   }),
#   url: Meteor.settings.private.tts.url,
# });


tone_analyzer = new ToneAnalyzerV3(
    version: '2017-09-21'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.tone.apikey
    })
    url: Meteor.settings.private.tone.url)


visual_recognition = new VisualRecognitionV3({
  version: '2018-03-19',
  authenticator: new IamAuthenticator({
    apikey: Meteor.settings.private.visual.apikey,
  }),
  url: Meteor.settings.private.visual.url,
});


# kevin lang
# bsbqj-_iQaA-ZwGUBK7NbGqZTaLvPHJgZW2OEXoN5C6P
# https://api.us-south.natural-language-understanding.watson.cloud.ibm.com/instances/5556901d-0bb1-4283-a2e3-d4cd8c42d15c


# tone
# QEDjdS8Btn2Qq1IFKWu1wirCfdCziCEJhaWt_Tn5MY87
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/6755dca9-6933-4529-81df-a985e6447170

# wDsUCpvjNiwBjDs5C1GvHwb970BDHBOcah_KXs-boFgG
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/6755dca9-6933-4529-81df-a985e6447170

# tone
# pIDLJyNdM8r4AB0lLmMNdGZtPSWUD3wXQfmXFBWxJ_l
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/37f08ca3-6c5b-439e-8270-78d96b54d635
# nlu
# WfilOI8O3M5n3cbU8byEczW_hctUm4viZDVaBSV-Gju3
# https://api.us-south.natural-language-understanding.watson.cloud.ibm.com/instances/b5195ac7-a729-46ea-b099-deb37d1dc65b

Meteor.methods
    call_tone: (doc_id)->
        @unblock()
        self = @
        doc = Docs.findOne doc_id
        # if doc.html or doc.body
        #     # stringed = JSON.stringify(doc.html, null, 2)
        # if mode is 'html'
        #     params =
        #         toneInput:doc.description
        #         content_type:'text/html'
        # if mode is 'text'
        params =
            toneInput: { 'text': doc.watson.analyzed_text }
            contentType: 'application/json'
        tone_analyzer.tone params, Meteor.bindEnvironment((err, response)->
            if response
                # console.dir response
                Docs.update { _id: doc_id},
                    $set:
                        tone: response
            )
        # else return

    call_visual: (doc_id, field)->
        @unblock()
        self = @
        doc = Docs.findOne doc_id
        # link = doc["#{field}"]
        # visual_recognition.classify(classify_params)
        #   .then(response => {
        #     const classifiedImages = response.result;
        #   })
        #   .catch(err => {
        #   });
        if doc.watson
            if doc.watson.metadata.image
                params =
                    url:doc.watson.metadata.image
        else
            params =
                url:doc.thumbnail
                # url:doc.url
            # images_file: images_file
            # classifier_ids: classifier_ids
        visual_recognition.classify params, Meteor.bindEnvironment((err, response)->
            if response
                visual_tags = []
                for tag in response.result.images[0].classifiers[0].classes
                    visual_tags.push tag.class.toLowerCase()
                Docs.update { _id: doc_id},
                    $set:
                        visual_classes: response.result.images[0].classifiers[0].classes
                        visual_tags:visual_tags
                    $addToSet:
                        tags:$each:visual_tags
        )

    call_watson: (doc_id, key, mode, durl) ->
        @unblock()
        self = @
        doc = Docs.findOne doc_id
        # console.log 'calling', doc_id, key, mode
        # if doc.skip_watson is false
        # else
        params =
            concepts:
                limit:10
            features:
                entities:
                    emotion: false
                    sentiment: false
                    mentions: false
                    limit: 10
                keywords:
                    emotion: false
                    sentiment: false
                    limit: 10
                concepts: {}
                categories:
                    explanation:false
                emotion: {}
                # relations: {}
                # semantic_roles: {}
                sentiment: {}
        if doc.data and doc.data.domain and doc.data.domain in ['i.redd.it','i.imgur.com','imgur.com','gyfycat.com','m.youtube.com','v.redd.it','giphy.com','youtube.com','youtu.be']
            params.url = "https://www.reddit.com#{doc.data.permalink}"
            params.returnAnalyzedText = false
            params.clean = false
        else 
            switch mode
                when 'html'
                    params.html = doc["#{key}"]
                    params.returnAnalyzedText = true
                    # params.html = doc.data.description
                    params.features.metadata = {}
                when 'text'
                    params.text = doc["#{key}"]
                    params.returnAnalyzedText = true
                    params.clean = true
                when 'url'
                    # params.url = doc["#{key}"]
                    params.url = durl
                    # console.log 'calling url', params.url, doc["#{key}"], key
                    # console.log 'calling url', params.url, doc[key], durl
                    # params.url = doc.data.link_url
                    params.returnAnalyzedText = true
                    params.clean = true
                    params.features.metadata = {}
                when 'stack'
                    # params.url = doc["#{key}"]
                    params.url = doc.link
                    params.returnAnalyzedText = true
                    params.features.metadata = {}
                    params.clean = true
                when 'video'
                    params.url = "https://www.reddit.com#{doc.data.permalink}"
                    params.returnAnalyzedText = true
                    params.clean = true
                    params.features.metadata = {}
                when 'image'
                    params.url = "https://www.reddit.com#{doc.data.permalink}"
                    params.returnAnalyzedText = true
                    params.clean = true
                    params.features.metadata = {}

        # console.log params

        natural_language_understanding.analyze params, Meteor.bindEnvironment((err, response)=>
            if err
                # if err.code is 400
                # console.log err
                unless err.code is 403
                    Docs.update doc_id,
                        $set:skip_watson:false
            else
                response = response.result
                # if Meteor.isDevelopment
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
                # if mode is 'url'
                Docs.update { _id: doc_id },
                    $set:
                        analyzed_text:response.analyzed_text
                        watson: response
                        max_emotion_name:max_emotion_name
                        max_emotion_percent:max_emotion_percent
                        sadness_percent: sadness_percent
                        joy_percent: joy_percent
                        fear_percent: fear_percent
                        anger_percent: anger_percent
                        disgust_percent: disgust_percent
                        watson_concepts: concept_array
                        watson_keywords: keyword_array
                        doc_sentiment_score: response.sentiment.document.score
                        doc_sentiment_label: response.sentiment.document.label



                adding_tags = []
                if response.categories
                    for category in response.categories
                        for category in category.label.split('/')
                            if category.length > 0
                                # adding_tags.push category
                                Docs.update doc_id,
                                    $addToSet: categories: category
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:adding_tags
                
                if response.entities and response.entities.length > 0
                    for entity in response.entities
                        unless entity.type is 'Quantity'
                            # if Meteor.isDevelopment
                            # else
                            Docs.update { _id: doc_id },
                                $addToSet:
                                    "#{entity.type}":entity.text
                                    # tags:entity.text.toLowerCase()
                                    tags:entity.text
                            
                concept_array = _.pluck(response.concepts, 'text')
                lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                keyword_array = _.pluck(response.keywords, 'text')
                lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()

                keywords_concepts = lowered_keywords.concat lowered_keywords
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:lowered_concepts
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:lowered_keywords
                # final_doc = Docs.findOne doc_id

                # if mode is 'url'
                #     # if doc.model is 'wikipedia'
                #     Meteor.call 'call_tone', doc_id, 'body', 'text', ->
                Meteor.call 'clear_blocklist_doc', doc_id, ->
                
                # Meteor.call 'log_doc_terms', doc_id, ->
                # if Meteor.isDevelopment
                return Docs.findOne(doc_id)
        )
        return Docs.findOne(doc_id)
