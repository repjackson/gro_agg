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


if Meteor.isClient
    Template.print_this.events
        'click .print_this': ->
            console.log @
    Template.comments.onCreated ->
        @autorun => Meteor.subscribe 'children', 'comment', Router.current().params.doc_id
    Template.comments.helpers
        doc_comments: ->
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.parentData()._id
            Docs.find
                model:'comment'
                parent_id:parent._id
                    
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                if Router.current().params.doc_id
                    parent = Docs.findOne Router.current().params.doc_id
                else
                    parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne Router.current().params.doc_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    parent_model:parent.model
                    body:comment
                t.$('.add_comment').val('')

        'click .remove_comment': ->
            if confirm 'confirm remove comment'
                Docs.remove @_id

#
    Template.call_watson.events
        'click .autotag': ->
            doc = Docs.findOne Router.current().params.doc_id
            console.log doc
            console.log @
    
            Meteor.call 'call_watson', doc._id, @key, @mode
#

    Template.remove_button.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                Docs.remove @_id
                # , 1000
