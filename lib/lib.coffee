@Docs = new Meteor.Collection 'docs'
@results = new Meteor.Collection 'results'
@Tags = new Meteor.Collection 'tags'
# @User_tags = new Meteor.Collection 'user_tags'
# @Level_results = new Meteor.Collection 'level_results'
# @Tag_results = new Meteor.Collection 'tag_results'


    # Router.route '/', (->
    #     @layout 'layout'
    #     @render 'family'
    # ), name:'root'
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


Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false


Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
# 
    doc._app = 'dao'
    # if Meteor.user()
    #     doc._author_id = Meteor.userId()
    #     doc._author_username = Meteor.user().username
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
    site_doc: ->
        Docs.findOne 
            model:'stack_site'
            name:@site
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



Meteor.users.helpers
    name: ->
        if @nickname
            "#{@nickname}"
        else if @first_name
            "#{@first_name} #{@last_name}"
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
