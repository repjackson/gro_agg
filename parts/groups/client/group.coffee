if Meteor.isClient
    Template.group_card.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000

    Template.group_edit.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
    Template.group_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
        Meteor.call 'mark_read', Router.current().params.doc_id, ->

    Template.group_card.events
        'click .view_group': ->
            Router.go "/group/#{@_id}/view"

    
    # Template.one_group_view.events
    #     'click .add_tag': ->
    #         selected_tags.push @valueOf()
    #         Meteor.call 'call_wiki', @valueOf(), ->
    #         Meteor.call 'search_reddit', selected_tags.array(), ->
                
    #         # Router.go '/'
    
    Template.join.helpers
        is_member: ->
            Meteor.userId() in @member_ids
    
    Template.join.events 
        'click .join':->
            Docs.update 
                $addToSet:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username
        'click .leave':->
            Docs.update 
                $pull:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username
        





if Meteor.isServer
    Meteor.publish 'group_posts', (group_id)->
        Docs.find   
            model:'post'
            group_id:group_id
    
    Meteor.publish 'group_tips', (group_id)->
        Docs.find   
            model:'tip'
            group_id:group_id
    
    Meteor.publish 'group_votes', (group_id)->
        Docs.find   
            model:'vote'
            parent_id:group_id
    
    
if Meteor.isClient
    Template.group_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.group_edit.events
        'click .delete_group': ->
            Swal.fire({
                title: "delete group?"
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
                        title: 'group removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/"
            )




    Template.group_edit.helpers
    Template.group_edit.events

if Meteor.isServer
    Meteor.methods
        publish_group: (group_id)->
            group = Docs.findOne group_id
            # target = Meteor.users.findOne group.recipient_id
            author = Meteor.users.findOne group._author_id

            console.log 'publishing group', offer
            Meteor.users.update author._id,
                $inc:
                    points: -offer.price
            Docs.update offer_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
