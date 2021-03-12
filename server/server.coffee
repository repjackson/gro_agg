Meteor.methods
    remove_doc: (doc_id)->
        Docs.remove doc_id

        

# Meteor.publish 'wikis', (
#     w_query
#     picked_tags
#     )->
#     Docs.find({
#         model:'wikipedia'
#     },{ 
#         limit:10
#     })
    


# Meteor.publish 'try', (title)->
#     Docs.find {
#         model:'rpost'
#     }, limit:10    

Meteor.publish 'doc_by_title', (title)->
    @unblock()
    Docs.find({
        title:title
        model:'wikipedia'
        "metadata.image":$exists:true
    }, {
        fields:
            title:1
            "metadata.image":1
    })




Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
        
        
        
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> false


Meteor.publish 'post_count', (
    picked_tags
    # picked_authors
    # picked_Locations
    # picked_times
    )->
    @unblock()
    match = {
        model:$in:['rpost','url']
        # is_private:$ne:true
    }
    # unless Meteor.userId()
    #     match.privacy='public'

    if picked_tags.length > 0
        match.tags = $all:picked_tags
        # if picked_authors.length > 0 then match.author = $all:picked_authors
        # if picked_Locations.length > 0 then match.location = $all:picked_Locations
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        Counts.publish this, 'post_count', Docs.find(match)
        return undefined
            
Meteor.publish 'rposts', (
    picked_tags
    # picked_domains
    # picked_authors
    # picked_time_tags
    # picked_Locations
    # picked_persons
    # sort_key='data.ups'
    # sort_direction=-1
    # limit=20
    # picked_times
    # picked_Locations
    # picked_authors
    # skip=0
    )->
        
    # @unblock()
    self = @
    match = {
        model:$in:['rpost','url']
        # is_private:$ne:true
        # group:$exists:false
    }
    # unless Meteor.userId()
    #     match.privacy='public'
    
    # if sort_key
    #     sk = sort_key
    # else
    #     sk = '_timestamp'
    # if nsfw
    #     match['data.over_18'] = true
    # else
    # match['data.over_18'] = false
    
    if picked_tags.length > 0
        match.tags = $all:picked_tags
        # if picked_Locations.length > 0 then match.location = $all:picked_Locations
        # if picked_authors.length > 0 then match['data.author'] = $all:picked_authors
        # if picked_domains.length > 0 then match['data.domain'] = $all:picked_domains
        # if picked_persons.length > 0 then match.Person = $all:picked_persons
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        Docs.find match,
            limit:20
            sort:
                "ups":-1
            # sort: "#{sort_key}":-1
            # skip:skip*20
        
    
           
Meteor.publish 'tags', (
    picked_tags
    toggle
    # picked_domains
    # picked_authors
    # picked_time_tags
    # picked_Locations
    # picked_persons
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:$in:['rpost','url']
        # model:'post'
        # is_private:$ne:true
        # sublove:sublove
    }


    # unless Meteor.userId()
    #     match.privacy='public'
    # if nsfw
    #     match['data.over_18'] = true
    # else
    # match['data.over_18'] = false
    # if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_tags.length > 0
        match.tags = $all:picked_tags
        # if picked_authors.length > 0 then match.author = $all:picked_authors
        # if picked_domains.length > 0 then match.domain = $all:picked_domains
        # if picked_Locations.length > 0 then match.Location = $all:picked_Locations
        # if picked_persons.length > 0 then match.Person = $all:picked_persons
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
        doc_count = Docs.find(match).count()
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:15 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        
        # Location_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "Location": 1 }
        #     { $unwind: "$Location" }
        #     { $group: _id: "$Location", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_location }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # Location_cloud.forEach (Location, i) ->
        #     self.added 'results', Random.id(),
        #         name: Location.name
        #         count: Location.count
        #         model:'Location'
        
        
        # Person_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "Person": 1 }
        #     { $unwind: "$Person" }
        #     { $group: _id: "$Person", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_Person }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # Person_cloud.forEach (Person, i) ->
        #     self.added 'results', Random.id(),
        #         name: Person.name
        #         count: Person.count
        #         model:'Person'
        
        
        # timestamp_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "timestamp_tags": 1 }
        #     { $unwind: "$timestamp_tags" }
        #     { $group: _id: "$timestamp_tags", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_time }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # timestamp_cloud.forEach (time, i) ->
        #     self.added 'results', Random.id(),
        #         name: time.name
        #         count: time.count
        #         model:'timestamp_tag'
        
        
        # time_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "time_tags": 1 }
        #     { $unwind: "$time_tags" }
        #     { $group: _id: "$time_tags", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_time }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # timestamp_cloud.forEach (time, i) ->
        #     self.added 'results', Random.id(),
        #         name: time.name
        #         count: time.count
        #         model:'time_tag'
        
        
        
        # author_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "data.author": 1 }
        #     # { $unwind: "$author" }
        #     { $group: _id: "$data.author", count: $sum: 1 }
        #     { $match: _id: $nin: picked_authors }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # author_cloud.forEach (author, i) ->
        #     self.added 'results', Random.id(),
        #         name: author.name
        #         count: author.count
        #         model:'author'
        
        # domain_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "data.domain": 1 }
        #     # { $unwind: "$author" }
        #     { $group: _id: "$data.domain", count: $sum: 1 }
        #     { $match: _id: $nin: picked_authors }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # domain_cloud.forEach (domain, i) ->
        #     self.added 'results', Random.id(),
        #         name: domain.name
        #         count: domain.count
        #         model:'domain'
        
        self.ready()
        
    


Meteor.publish 'wiki_doc', (
    # doc_id
    picked_tags
    )->
    # console.log 'dummy', dummy
    # console.log 'publishing wiki doc', picked_tags
    @unblock()
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
            "metadata":1
            tags:1
            model:1


Meteor.publish 'alpha_combo', (selected_tags)->
    @unblock()
    Docs.find 
        model:'alpha'
        # query: $in: selected_tags
        query: selected_tags.toString()
