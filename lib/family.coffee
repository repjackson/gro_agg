if Meteor.isClient        
    Template.family.onCreated ->
        Session.setDefault('view_section', 'posts')
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'tribe_by_name', Router.current().params.name
        # @autorun => Meteor.subscribe 'model_docs', 'feature'
        @autorun => Meteor.subscribe 'tribe_members',Router.current().params.name
        # @autorun => Meteor.subscribe 'tribe_template_from_tribe_id', Router.current().params.doc_id

    Template.family.onCreated ->
        @autorun => Meteor.subscribe 'fam_posts'
    #     Meteor.userId() in @member_ids

    Template.family.helpers
        tribe_posts: ->
            Docs.find 
                model:'post'
                tribe:'jpfam'

if Meteor.isServer 
    Meteor.publish 'fam_posts', ->
        Docs.find 
            model:'post'
            tribe:'jpfam'