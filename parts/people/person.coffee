if Meteor.isClient
    Template.people.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'person'
        
    Template.people.helpers
        people: ->
            Docs.find
                model:'person'
        
        
    # Template.person_layout.onCreated ->
    #     @autorun => Meteor.subscribe 'person_by_slug', Router.current().params.person_slug
    #     # @autorun => Meteor.subscribe 'children', 'person_update', Router.current().params.doc_id
    #     @autorun => Meteor.subscribe 'members', Router.current().params.doc_id
    #     @autorun => Meteor.subscribe 'person_dishes', Router.current().params.person_slug
    # Template.person_layout.helpers
    #     current_person: ->
    #         Docs.findOne
    #             model:'person'
    #             slug: Router.current().params.person_slug
    # Template.person_layout.helpers
    #     current_person: ->
    #         Docs.findOne
    #             model:'person'
    #             slug: Router.current().params.person_slug

    # Template.person_dashboard.events
    #     'click .refresh_person_stats': ->
    #         Meteor.call 'calc_person_stats', Router.current().params.person_slug, ->
        # 'click .join': ->
        #     Docs.update
        #         model:'person'
        #         _author_id: Meteor.userId()
        # 'click .person_leave': ->
        #     my_person = Docs.findOne
        #         model:'person'
        #         _author_id: Meteor.userId()
        #         ballot_id: Router.current().params.doc_id
        #     if my_person
        #         Docs.update my_person._id,
        #             $set:value:'no'
        #     else
        #         Docs.insert
        #             model:'person'
        #             ballot_id: Router.current().params.doc_id
        #             value:'no'


if Meteor.isServer
    Meteor.publish 'post_person', (post_id)->
        post = Docs.findOne post_id
        Docs.find
            model:'person'
            _id:post.person_id


    Meteor.publish 'model_docs', (model)->
        Docs.find
            model:model
        , {limit:10}
            




Router.route '/person/:doc_id/edit', -> @render 'person_edit'

if Meteor.isClient
    Template.person_edit.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'person'
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.person_edit.events
        'click .add_post': ->
            new_id = Docs.insert
                model:'post'
                person_id: Router.current().params.doc_id
            
            Router.go "/post/#{new_id}/edit"
            
    Template.person_edit.helpers
        person_posts: ->
            Docs.find
                model:'post'
                
                
Router.route '/person/:doc_id', -> @render 'person_view'

if Meteor.isClient
    Template.person_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'person_posts', Router.current().params.doc_id
    Template.person_view.events
        'click .add_post': ->
            new_id = 
                Docs.insert
                    model:'post'
                    person_id: Router.current().params.doc_id
            Router.go "/post/#{new_id}/edit"
                
    Template.person_view.helpers
        person_posts: ->
            Docs.find
                model:'post'
                person_id:Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'person_posts', (person_id)->
        Docs.find
            model:'post'
            person_id:person_id