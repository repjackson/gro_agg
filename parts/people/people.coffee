if Meteor.isClient
    Router.route '/people/', (->
        @layout 'layout'
        @render 'people'
        ), name:'people'
    

    Template.people.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_person_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'person'
    Template.person_view.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_person_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'all_users'
        
        
        
    
    Template.people.helpers
        result_tags: -> results.find(model:'person_tag')

        person_docs: ->
            Docs.find 
                model:'person'
                # can_buy:true
                 
    Template.people.events
        'click .add_person': ->
            new_id =
                Docs.insert
                    model:'person'
            Router.go "/person/#{new_id}/edit"




if Meteor.isServer
    # Meteor.publish 'members', (person_id)->
    #     Meteor.users.find
    #         _id:$in:@member_ids

    Meteor.publish 'person_by_slug', (person_slug)->
        Docs.find
            model:'person'
            slug:person_slug
    Meteor.methods
        calc_person_stats: (person_slug)->
            person = Docs.findOne
                model:'person'
                slug: person_slug

            member_count =
                person.member_ids.length

            person_members =
                Meteor.users.find
                    _id: $in: person.member_ids

            dish_count = 0
            dish_ids = []
            for member in person_members.fetch()
                member_dishes =
                    Docs.find(
                        model:'dish'
                        _author_id:member._id
                    ).fetch()
                for dish in member_dishes
                    console.log 'dish', dish.title
                    dish_ids.push dish._id
                    dish_count++
            # dish_count =
            #     Docs.find(
            #         model:'dish'
            #         person_id:person._id
            #     ).count()
            person_count =
                Docs.find(
                    model:'person'
                    person_id:person._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    person_id:person._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            person_persons =
                Docs.find(
                    model:'person'
                    person_id:person._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update person._id,
                $set:
                    member_count:member_count
                    person_count:person_count
                    dish_count:dish_count
                    total_credit_exchanged:total_credit_exchanged
                    dish_ids:dish_ids
