

Meteor.publish 'wiki_doc', (
    # doc_id
    picked_tags
    )->
    # console.log 'dummy', dummy
    # console.log 'publishing wiki doc', picked_tags

    self = @
    match = {}

    match.model = 'wikipedia'
    match.title = $in:picked_tags
    # console.log 'query length', query.length
    # if picked_tags.length > 1
    #     match.tags = $all: picked_tags
        
    Docs.find match,
        fields:
            title:1
            "analyzed_text":1
            url:1
            "watson.metadata":1
            tags:1
            model:1


Meteor.publish 'alpha_combo', (selected_tags)->
    Docs.find 
        model:'alpha'
        # query: $in: selected_tags
        query: selected_tags.toString()
