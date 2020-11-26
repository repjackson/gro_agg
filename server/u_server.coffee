Meteor.publish 'selected_users', (
    selected_user_tags
    selected_user_site
    selected_user_location
    username_query
    location_query
    )->
    match = {model:'stackuser'}
    if username_query
        match.display_name = {$regex:"#{username_query}", $options: 'i'}
    if location_query
        match.location = {$regex:"#{location_query}", $options: 'i'}

    if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
    if selected_user_site then match.site = selected_user_site
    if selected_user_location then match.location = selected_user_location
    Docs.find match,
        limit:20
        sort:
            reputation:-1



Meteor.publish 'user_tags', (
    selected_user_tags
    selected_user_site
    selected_user_location
    username_query
    location_query=''
    # view_mode
    # limit
)->
    self = @
    match = {model:'stackuser'}
    if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
    if selected_user_site then match.site = selected_user_site
    if username_query    
        match.display_name = {$regex:"#{username_query}", $options: 'i'}
    if location_query.length > 1 
        match.location = {$regex:"#{location_query}", $options: 'i'}
    if selected_user_location then match.location = selected_user_location
    # match.model = 'item'
    # if view_mode is 'users'
    #     match.bought = $ne:true
    #     match._author_id = $ne: Meteor.userId()
    # if view_mode is 'bought'
    #     match.bought = true
    #     match.buyer_id = Meteor.userId()
    # if view_mode is 'selling'
    #     match.bought = $ne:true
    #     match._author_id = Meteor.userId()
    # if view_mode is 'sold'
    #     match.bought = true
    #     match._author_id = Meteor.userId()
    doc_count = Docs.find(match).count()

    cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_user_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    cloud.forEach (user_tag, i) ->
        self.added 'results', Random.id(),
            name: user_tag.name
            count: user_tag.count
            model:'user_tag'
            index: i


    site_cloud = Docs.aggregate [
        { $match: match }
        { $project: "site": 1 }
        { $group: _id: "$site", count: $sum: 1 }
        # { $match: site: $ne: selected_user_site }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit: 10 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    site_cloud.forEach (site_result, i) ->
        self.added 'results', Random.id(),
            name: site_result.name
            model:'user_site'
            count: site_result.count
            index: i
    
    location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location": 1 }
        { $group: _id: "$location", count: $sum: 1 }
        # { $match: location: $ne: selected_user_location }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit: 10 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    location_cloud.forEach (location_result, i) ->
        self.added 'results', Random.id(),
            name: location_result.name
            model:'user_location'
            count: location_result.count
            index: i

    self.ready()
