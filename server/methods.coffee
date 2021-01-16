Meteor.methods
    # hi: ->
    # stringify_tags: ->
    #     docs = Docs.find({
    #         tags: $exists: true
    #         tags_string: $exists: false
    #     },{limit:1000})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         tags_string = doc.tags.toString()
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #
    log_view: (doc_id)->
        console.log 'removing doc', doc_id
        Docs.update doc_id, 
            $inc:_views:1
        if Meteor.userId()
            Docs.update doc_id, 
                $addToSet:
                    _viewer_usernames:Meteor.user().username
            
    remove_doc: (doc_id)->
        console.log 'removing doc', doc_id
        Docs.remove doc_id
        
        
    log_doc_terms: (doc_id)->
        doc = Docs.findOne doc_id
        if doc.tags
            for tag in doc.tags
                Meteor.call 'log_term', tag, ->


    # log_term: (term_title)->
    #     found_term =
    #         Terms.findOne
    #             title:term_title
    #     unless found_term
    #         Terms.insert
    #             title:term_title
    #         # if Meteor.user()
    #         #     Meteor.users.update({_id:Meteor.userId()},{$inc: karma: 1}, -> )
    #     else
    #         Terms.update({_id:found_term._id},{$inc: count: 1}, -> )
    #         Meteor.call 'call_wiki', @term_title, =>
    #             Meteor.call 'calc_term', @term_title, ->

    # calc_term: (term_title)->
    #     found_term =
    #         Terms.findOne
    #             title:term_title
    #     unless found_term
    #         Terms.insert
    #             title:term_title
    #     if found_term
    #         found_term_docs =
    #             Docs.find {
    #                 model:'reddit'
    #                 tags:$in:[term_title]
    #             }, {
    #                 sort:
    #                     points:-1
    #                     ups:-1
    #                 limit:10
    #             }



    #         unless found_term.image
    #             found_wiki_doc =
    #                 Docs.findOne
    #                     model:$in:['wikipedia']
    #                     # model:$in:['wikipedia','reddit']
    #                     title:term_title
    #             found_reddit_doc =
    #                 Docs.findOne
    #                     model:$in:['reddit']
    #                     "watson.metadata.image": $exists:true
    #                     # model:$in:['wikipedia','reddit']
    #                     title:term_title
    #             if found_wiki_doc
    #                 if found_wiki_doc.watson.metadata.image
    #                     Terms.update term._id,
    #                         $set:image:found_wiki_doc.watson.metadata.image


    # lookup: =>
    #     selection = @words[4000..4500]
    #     for word in selection
    #         # Meteor.setTimeout ->
    #         Meteor.call 'search_reddit', ([word])
    #         # , 5000

    rename_key:(old_key,new_key,parent)->
        Docs.update parent._id,
            $pull:_keys:old_key
        Docs.update parent._id,
            $addToSet:_keys:new_key
        Docs.update parent._id,
            $rename:
                "#{old_key}": new_key
                "_#{old_key}": "_#{new_key}"

    remove_tag: (tag)->
        results =
            Docs.find {
                tags: $in: [tag]
            }
        # Docs.remove(
        #     tags: $in: [tag]
        # )
        for doc in results.fetch()
            res = Docs.update doc._id,
                $pull: tags: tag
