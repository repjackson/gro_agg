@Docs = new Meteor.Collection 'docs'
@results = new Meteor.Collection 'results'
# @Tag_results = new Meteor.Collection 'tag_results'
Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false



Meteor.methods
    log_view: (doc_id)->
        doc = Docs.findOne doc_id
        # console.log 'logging view', doc_id
        Docs.update doc_id, 
            $inc:views:1


