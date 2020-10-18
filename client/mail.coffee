if Meteor.isClient
    Router.route '/mail', (->
        @layout 'layout'
        @render 'mail'
        ), name:'mail'
    
    Template.message_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
  
    Template.message_edit.onRendered ->
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 2000

    Template.message_view.onRendered ->
        # Meteor.call 'log_view', Router.current().params.doc_id
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 2000
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
        # Meteor.call 'mark_read', Router.current().params.doc_id, ->
        
    Template.message_card.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
    Template.message_card.events
        'click .view_message': ->
            Router.go "/message/#{@_id}/view"

                
    Template.message_card.events
        'click .add_tag': ->
            selected_tags.push @valueOf()
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_ph', selected_tags.array(), ->
            Meteor.call 'search_reddit', selected_tags.array(), ->
                
                
    
if Meteor.isClient
    Template.message_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.message_edit.events
        'click .delete_message': ->
            Swal.fire({
                title: "delete message?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'message removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/"
            )