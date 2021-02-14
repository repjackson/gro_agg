@Docs = new Meteor.Collection 'docs'
@results = new Meteor.Collection 'results'
# @User_tags = new Meteor.Collection 'user_tags'
# @Level_results = new Meteor.Collection 'level_results'
# @Tag_results = new Meteor.Collection 'tag_results'


    # Router.route '/', (->
    #     @layout 'layout'
    #     @render 'family'
    # ), name:'root'

Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'home'
    loadingTemplate: 'splash'
    trackPageView: false


Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
# 
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
        doc.timestamp_tags = date_array
    return


Docs.helpers
    when: -> moment(@_timestamp).fromNow()
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

