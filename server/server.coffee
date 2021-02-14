# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> true


Meteor.methods
    # hi: ->
    # stringify_tags: ->
    #     docs = Docs.find({
    #         tags: $exists: true
    #         tags_string: $exists: false
    #     },{limit:500})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         tags_string = doc.tags.toString()
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #

Meteor.publish 'count', (
    picked_tags
    )->
    match = {
        model:'rpost'
    }

    match.tags = $all:picked_tags
    if picked_tags.length
        Counts.publish this, 'counter', Docs.find(match)
        return undefined
            
Meteor.publish 'posts', (
    picked_tags
    )->
    self = @
    match = {
        model:'rpost'
    }
    if picked_tags.length
        match.tags = $all:picked_tags
        
    
        console.log 'match', match
        Docs.find match,
            limit: 20
            # sort: "#{sk}":-1
            sort: ups:-1
    
    
    
           
Meteor.publish 'tags', (
    picked_tags
    toggle
    )->
    # @unblock()
    self = @
    match = {
        model: 'rpost'
    }
    if picked_tags.length
        match.tags = $all:picked_tags
        doc_count = Docs.find(match).count()
        console.log 'doc_count', doc_count
        console.log 'tag match', match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        
        
        self.ready()
        