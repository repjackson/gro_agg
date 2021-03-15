if Meteor.isClient
    Router.route '/posts/', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'
    

    Template.posts.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_post_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_person_posts'
    Template.post_view.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_post_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'all_users'
        
        
        
    
    Template.posts.helpers
        result_tags: -> results.find(model:'post_tag')

        post_docs: ->
            Docs.find 
                model:'post'
                # can_buy:true
                 
    Template.posts.events
        'click .add_post': ->
            new_id =
                Docs.insert
                    model:'post'
            Router.go "/post/#{new_id}/edit"




if Meteor.isServer
    Meteor.publish 'members', (post_id)->
        Meteor.users.find
            _id:$in:@member_ids

    Meteor.publish 'post_by_slug', (post_slug)->
        Docs.find
            model:'post'
            slug:post_slug
    Meteor.publish 'all_person_posts', ()->
        Docs.find
            model:'post'
            person_id:$exists:true
    Meteor.methods
        # calc_post_stats: (post_slug)->
        #     post = Docs.findOne
        #         model:'post'
        #         slug: post_slug

        #     member_count =
        #         post.member_ids.length

        #     post_members =
        #         Meteor.users.find
        #             _id: $in: post.member_ids

        #     dish_count = 0
        #     dish_ids = []
        #     for member in post_members.fetch()
        #         member_dishes =
        #             Docs.find(
        #                 model:'dish'
        #                 _author_id:member._id
        #             ).fetch()
        #         for dish in member_dishes
        #             console.log 'dish', dish.title
        #             dish_ids.push dish._id
        #             dish_count++
        #     # dish_count =
        #     #     Docs.find(
        #     #         model:'dish'
        #     #         post_id:post._id
        #     #     ).count()
        #     post_count =
        #         Docs.find(
        #             model:'post'
        #             post_id:post._id
        #         ).count()

        #     order_cursor =
        #         Docs.find(
        #             model:'order'
        #             post_id:post._id
        #         )
        #     order_count = order_cursor.count()
        #     total_credit_exchanged = 0
        #     for order in order_cursor.fetch()
        #         if order.order_price
        #             total_credit_exchanged += order.order_price
        #     post_posts =
        #         Docs.find(
        #             model:'post'
        #             post_id:post._id
        #         ).fetch()

        #     console.log 'total_credit_exchanged', total_credit_exchanged


        #     Docs.update post._id,
        #         $set:
        #             member_count:member_count
        #             post_count:post_count
        #             dish_count:dish_count
        #             total_credit_exchanged:total_credit_exchanged
        #             dish_ids:dish_ids
