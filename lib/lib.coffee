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



Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")

    # doc.app = 'dao'

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



Meteor.methods
    log_view: (doc_id)->
        Docs.update doc_id,
            $inc:dao_views:1
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