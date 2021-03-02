@Docs = new Meteor.Collection 'docs'
@results = new Meteor.Collection 'results'
# @Tag_results = new Meteor.Collection 'tag_results'



Meteor.methods
    log_view: (doc_id)->
        doc = Docs.findOne doc_id
        # console.log 'logging view', doc_id
        Docs.update doc_id, 
            $inc:views:1


