if Meteor.isClient
    Router.route '/course/:doc_id/view', (->
        @layout 'layout'
        @render 'course_view'
        ), name:'course_view'
    Template.course_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'shop_from_course_id', Router.current().params.doc_id
   
   
    Router.route '/course/:doc_id/edit', (->
        @layout 'layout'
        @render 'course_edit'
        ), name:'course_edit'

    Template.course_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.course_edit.onRendered ->


    Template.course_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_menu', @_id, =>
                    Router.go "/menu/#{@_id}/view"


if Meteor.isServer
    Meteor.publish 'shop_from_course_id', (course_id)->
        course = Docs.findOne course_id
        console.log 'course', course
        Docs.find
            # model:'shop'
            _id:course.shop_id