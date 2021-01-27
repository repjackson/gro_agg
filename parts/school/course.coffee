if Meteor.isClient
    Router.route '/course/:doc_id', (->
        @layout 'course_view_layout'
        @render 'course_home'
        ), name:'course_home'
    Router.route '/course/:doc_id/content', (->
        @layout 'course_view_layout'
        @render 'course_content'
        ), name:'course_content'
    Router.route '/course/:doc_id/calendar', (->
        @layout 'course_view_layout'
        @render 'course_calendar'
        ), name:'course_calendar'
    Router.route '/course/:doc_id/assignments', (->
        @layout 'course_view_layout'
        @render 'course_assignments'
        ), name:'course_assignments'
    Router.route '/course/:doc_id/discussions', (->
        @layout 'course_view_layout'
        @render 'course_discussions'
        ), name:'course_discussions'
    Router.route '/course/:doc_id/groups', (->
        @layout 'course_view_layout'
        @render 'course_groups'
        ), name:'course_groups'
    Router.route '/course/:doc_id/quizzes', (->
        @layout 'course_view_layout'
        @render 'course_quizzes'
        ), name:'course_quizzes'
    Router.route '/course/:doc_id/surveys', (->
        @layout 'course_view_layout'
        @render 'course_surveys'
        ), name:'course_surveys'
    Router.route '/course/:doc_id/classlist', (->
        @layout 'course_view_layout'
        @render 'course_classlist'
        ), name:'course_classlist'
    Router.route '/course/:doc_id/progress', (->
        @layout 'course_view_layout'
        @render 'course_progress'
        ), name:'course_progress'
    Router.route '/course/:doc_id/grades', (->
        @layout 'course_view_layout'
        @render 'course_grades'
        ), name:'course_grades'
    Router.route '/course/:doc_id/locker', (->
        @layout 'course_view_layout'
        @render 'course_locker'
        ), name:'course_locker'
    Template.course_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'shop_from_course_id', Router.current().params.doc_id
   
   
    Router.route '/course/:doc_id/edit', (->
        @layout 'layout'
        @render 'course_edit'
        ), name:'course_edit'

    Template.course_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.course_edit.onRendered ->


    Template.course_home.events
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    course_id:Router.current().params.doc_id
            Router.go "/course/#{Router.current().params.doc_id}/post/#{new_id}/edit"
            
            
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