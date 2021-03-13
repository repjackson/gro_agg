Router.route '/person/:person_slug', (->
    @layout 'person_layout'
    @render 'person_dashboard'
    ), name:'person_dashboard'
Router.route '/person/:person_slug/members', (->
    @layout 'person_layout'
    @render 'person_members'
    ), name:'person_members'
Router.route '/person/:person_slug/credit', (->
    @layout 'person_layout'
    @render 'person_credit'
    ), name:'person_credit'
Router.route '/person/:person_slug/meals', (->
    @layout 'person_layout'
    @render 'person_meals'
    ), name:'person_meals'
Router.route '/person/:person_slug/dishes', (->
    @layout 'person_layout'
    @render 'person_dishes'
    ), name:'person_dishes'
Router.route '/person/:person_slug/voting', (->
    @layout 'person_layout'
    @render 'person_voting'
    ), name:'person_voting'
Router.route '/person/:person_slug/events', (->
    @layout 'person_layout'
    @render 'person_events'
    ), name:'person_events'
Router.route '/person/:person_slug/food', (->
    @layout 'person_layout'
    @render 'person_food'
    ), name:'person_food'
Router.route '/person/:person_slug/products', (->
    @layout 'person_layout'
    @render 'person_products'
    ), name:'person_products'
Router.route '/person/:person_slug/services', (->
    @layout 'person_layout'
    @render 'person_services'
    ), name:'person_services'
Router.route '/person/:person_slug/stats', (->
    @layout 'person_layout'
    @render 'person_stats'
    ), name:'person_stats'
Router.route '/person/:person_slug/transactions', (->
    @layout 'person_layout'
    @render 'person_transactions'
    ), name:'person_transactions'
Router.route '/person/:person_slug/messages', (->
    @layout 'person_layout'
    @render 'person_messages'
    ), name:'person_messages'
Router.route '/person/:person_slug/posts', (->
    @layout 'person_layout'
    @render 'person_posts'
    ), name:'person_posts'
Router.route '/person/:person_slug/settings', (->
    @layout 'person_layout'
    @render 'person_settings'
    ), name:'person_settings'



if Meteor.isClient
    Template.person_layout.onCreated ->
        @autorun => Meteor.subscribe 'person_by_slug', Router.current().params.person_slug
        # @autorun => Meteor.subscribe 'children', 'person_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'person_dishes', Router.current().params.person_slug
    Template.person_layout.helpers
        current_person: ->
            Docs.findOne
                model:'person'
                slug: Router.current().params.person_slug

    Template.person_dashboard.events
        'click .refresh_person_stats': ->
            Meteor.call 'calc_person_stats', Router.current().params.person_slug, ->
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
    Meteor.publish 'person_dishes', (person_slug)->
        person = Docs.findOne
            model:'person'
            slug:person_slug
        Docs.find
            model:'dish'
            _id: $in: person.dish_ids




Router.route '/person/:doc_id/edit', -> @render 'person_edit'

if Meteor.isClient
    Template.person_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'person_options', Router.current().params.doc_id
    Template.person_edit.events
        'click .add_option': ->
            Docs.insert
                model:'person_option'
                ballot_id: Router.current().params.doc_id
    Template.person_edit.helpers
        options: ->
            Docs.find
                model:'person_option'
