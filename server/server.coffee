# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> true


# Meteor.publish 'model_count', (
#     model
#     )->
#     match = {model:model}
    
#     Counts.publish this, 'model_counter', Docs.find(match)
#     return undefined

Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
        

Meteor.publish 'wikis', (
    w_query
    selected_tags
    )->
    Docs.find({
        model:'wikipedia'
    },{ 
        limit:10
    })
    

Meteor.publish 'doc_by_title', (title)->
    Docs.find
        title:title
        model:'wikipedia'

Meteor.publish 'doc_by_title_small', (title)->
    Docs.find({
        title:title
        model:'wikipedia'
    }, {
        fields:
            title:1
            "watson.metadata.image":1
    })

Meteor.publish 'comments', (doc_id)->
    Docs.find
        model:'comment'
        parent_id:doc_id

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
        console.log 'logging view', doc_id
        Docs.update doc_id, 
            $inc:views:1
            
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


Meteor.methods

    # import_tests: ->
    #     # myobject = HTTP.get(Meteor.absoluteUrl("/public/tests.json")).data;
    #     myjson = JSON.parse(Assets.getText("tests.json"));
    #     console.log myjson



    global_remove: (keyname)->
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()




    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id