@Docs = new Meteor.Collection 'docs'
@results = new Meteor.Collection 'results'
@Tags = new Meteor.Collection 'tags'
# @Tag_results = new Meteor.Collection 'tag_results'


if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"

if Meteor.isServer
    # console.log Meteor.settings.private.cloudinary_key
    # console.log Meteor.settings.private.cloudinary_secret
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.private.cloudinary_key
        api_secret: Meteor.settings.private.cloudinary_secret


Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    doc._author_id = Meteor.userId()
    doc._author_username = Meteor.user().username

    doc._app = 'dao'

    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # doc.points = 0
    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        doc._timestamp_tags = date_array
    return


Docs.helpers
    when: -> moment(@_timestamp).fromNow()
    site_doc: ->
        Docs.findOne 
            model:'stack_site'
            name:@site
    seven_tags: ->
        if @tags
            @tags[..7]
    question_bounties: ->
        Docs.find 
            model:'stack_bounty'
            question_id:@qid

    five_tags: ->
        if @tags
            @tags[..5]
    three_tags: ->
        if @tags
            @tags[..3]
    initials: ->
        @username[..1]
    _author: -> Meteor.users.findOne @_author_id
    _buyer: -> Meteor.users.findOne @buyer_id
    recipient: ->
        Meteor.users.findOne @recipient_id
    
    is_visible: -> @published in [0,1]
    is_published: -> @published is 1
    is_anonymous: -> @published is 0
    is_private: -> @published is -1
    is_read: ->
        @read_ids and Meteor.userId() in @read_ids

    enabled_features: () ->
        Docs.find
            model:'feature'
            _id:$in:@enabled_feature_ids


    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Meteor.users.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Meteor.users.findOne downvoter_id
                downvoters.push downvoter
            downvoters
Meteor.users.helpers
    name: ->
        if @nickname
            "#{@nickname}"
        else if @first_name
            "#{@first_name}" 
            # if @last_name
            #     |"#{@last_name}"
        else
            "#{@username}"
    shortname: ->
        if @nickname
            "#{@nickname}"
        else if @first_name
            "#{@first_name}"
        else
            "#{@username}"
    email_address: -> if @emails and @emails[0] then @emails[0].address
    email_verified: -> if @emails and @emails[0] then @emails[0].verified
    first_five_tags: ->
        if @tags
            @tags[..5]
    has_points: -> @points > 0
    # is_tech_admin: ->
    #     @_id in ['vwCi2GTJgvBJN5F6c','Dw2DfanyyteLytajt','LQEJBS6gHo3ibsJFu','YFPxjXCgjhMYEPADS','RWPa8zfANCJsczDcQ']





Meteor.methods
    upvote_sentence: (doc_id, sentence)->
        if sentence.weight
            Docs.update(
                { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
                { $inc: { "tone.result.sentences_tone.$.weight": 1 } }
            )
        else
            Docs.update(
                { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
                { $set: { "tone.result.sentences_tone.$.weight": 1 } }
            )
    tag_sentence: (doc_id, sentence, tag)->
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $addToSet: { "tone.result.sentences_tone.$.tags": tag } }
        )

    reset_sentence: (doc_id, sentence)->
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $set: { "tone.result.sentences_tone.$.weight": -2 } }
        )


    downvote_sentence: (doc_id, sentence)->
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $inc: { "tone.result.sentences_tone.$.weight": -1 } }
        )
    check_url: (str)->
        pattern = new RegExp('^(https?:\\/\\/)?'+ # protocol
        '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ # domain name
        '((\\d{1,3}\\.){3}\\d{1,3}))'+ # OR ip (v4) address
        '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ # port and path
        '(\\?[;&a-z\\d%_.~+=-]*)?'+ # query string
        '(\\#[-a-z\\d_]*)?$','i') # fragment locator
        return !!pattern.test(str)
        
        

    pin: (doc)->
        if doc.pinned_ids and Meteor.userId() in doc.pinned_ids
            Docs.update doc._id,
                $pull: pinned_ids: Meteor.userId()
                $inc: pinned_count: -1
        else
            Docs.update doc._id,
                $addToSet: pinned_ids: Meteor.userId()
                $inc: pinned_count: 1

    subscribe: (doc)->
        if doc.subscribed_ids and Meteor.userId() in doc.subscribed_ids
            Docs.update doc._id,
                $pull: subscribed_ids: Meteor.userId()
                $inc: subscribed_count: -1
        else
            Docs.update doc._id,
                $addToSet: subscribed_ids: Meteor.userId()
                $inc: subscribed_count: 1

    upvote: (doc)->
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $addToSet: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        credit:.02
                        upvotes:1
                        downvotes:-1
                        points:2
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        credit:-.01
                        upvotes:-1
                        points:-1
            else
                Docs.update doc._id,
                    $addToSet: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        points:1
                        upvotes:1
                        credit:.01
            Meteor.users.update doc._author_id,
                $inc:points:1
        else
            Docs.update doc._id,
                $inc:
                    anon_credit:.01
                    anon_upvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_points:1

    downvote: (doc)->
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $addToSet: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        credit:-.02
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        points:1
                        credit:.01
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        points:-1
                        credit:-.01
                        downvotes:1
            Meteor.users.update doc._author_id,
                $inc:points:-1
        else
            Docs.update doc._id,
                $inc:
                    anon_credit:-1
                    anon_downvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_points:-1        