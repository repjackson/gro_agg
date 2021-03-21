@Tags = new Meteor.Collection 'tags'
@Terms = new Meteor.Collection 'terms'
@Docs = new Meteor.Collection 'docs'
@results = new Meteor.Collection 'results'
# @Tag_results = new Meteor.Collection 'tag_results'

Meteor.methods
    log_view: (doc_id)->
        doc = Docs.findOne doc_id
        # console.log 'logging view', doc_id
        Docs.update doc_id, 
            $inc:views:1


Docs.helpers
    _author: -> Meteor.users.findOne @_author_id
    when: -> moment(@_timestamp).fromNow()
    is_read: -> @read_ids and Meteor.userId() in @read_ids
    seven_tags: ->
        if @tags
            @tags[..7]
    five_tags: ->
        if @tags
            @tags[..5]
    ten_tags: ->
        if @tags
            @tags[..10]
    three_tags: ->
        if @tags
            @tags[..3]



Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")

    doc.app = 'dao'

    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    doc.points = 0

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array
    return