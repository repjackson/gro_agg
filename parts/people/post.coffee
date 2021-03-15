
Router.route '/post/:doc_id/edit', -> @render 'post_edit'
Router.route '/post/:doc_id/', -> @render 'post_view'

if Meteor.isClient
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_person', Router.current().params.doc_id
    Template.post_edit.events
        'click .add_post': ->
            new_id = Docs.insert
                model:'post'
                person_id: Router.current().params.doc_id
            
            Router.go "/post/#{new_id}/edit"
            
    Template.post_edit.helpers
        options: ->
            Docs.find
                model:'person_option'
                
    Template.post_edit.events
        'click .delete_post': ->
            if confirm 'delete?'
                Docs.remove @_id
            Router.route '/post/:doc_id/edit', -> @render 'post_edit'

if Meteor.isClient
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_person', Router.current().params.doc_id
    Template.post_view.events
        'click .add_post': ->
            new_id = Docs.insert
                model:'post'
                person_id: Router.current().params.doc_id
            
            Router.go "/post/#{new_id}/edit"
            
    Template.post_view.helpers
        options: ->
            Docs.find
                model:'person_option'
                
    Template.post_view.events
        'click .delete_post': ->
            if confirm 'delete?'
                Docs.remove @_id
            