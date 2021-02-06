Meteor.publish 'love_count', (
    selected_tags
    selected_author_tags
    selected_location_tags
    )->
    match = {model:'love'}
        
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    if selected_author_tags.length > 0 then match.author_tags = $all:selected_author_tags
    if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    Counts.publish this, 'counter', Docs.find(match)
    return undefined
            
Meteor.publish 'expressions', (
    selected_tags
    selected_author_tags
    selected_location_tags
    sort_key
    sort_direction
    skip=0
    )->
    self = @
    match = {
        model:'love'
        # love: love
    }
    if sort_key
        sk = sort_key
    else
        sk = '_authorstamp'
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    # if selected_author_tags.length > 0 then match.author_tags = $all:selected_author_tags
    if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    # if selected_sublove_domains.length > 0 then match.domain = $all:selected_sublove_domains
    # if selected_love_authors.length > 0 then match.author = $all:selected_love_authors
    # console.log 'skip', skip
    Docs.find match,
        limit:10
        sort: "#{sk}":-1
        # skip:skip*20
    
    
# Meteor.methods    
    # tagify_love: (love)->
    #     doc = Docs.findOne love
    #     # moment(doc.date).fromNow()
    #     # authorstamp = Date.now()

    #     doc._authorstamp_long = moment(doc._authorstamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    #     # doc._app = 'love'
    
    #     date = moment(doc.date).format('Do')
    #     weekdaynum = moment(doc.date).isoWeekday()
    #     weekday = moment().isoWeekday(weekdaynum).format('dddd')
    
    #     hour = moment(doc.date).format('h')
    #     minute = moment(doc.date).format('m')
    #     ap = moment(doc.date).format('a')
    #     month = moment(doc.date).format('MMMM')
    #     year = moment(doc.date).format('YYYY')
    
    #     # doc.points = 0
    #     # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    #     date_array = [ap, weekday, month, date, year]
    #     if _
    #         date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    #         doc._authorstamp_tags = date_array
    #         # console.log 'love', date_array
    #         Docs.update love, 
    #             $set:addedauthor_tags:date_array
    
           
Meteor.publish 'love_tags', (
    selected_tags
    selected_author_tags
    selected_location_tags
    # selected_love_authors
    # view_bounties
    # view_unanswered
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'love'
        # love:love
        # sublove:sublove
    }

    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    # if selected_sublove_domain.length > 0 then match.domain = $all:selected_sublove_domain
    if selected_author_tags.length > 0 then match.author_tags = $all:selected_author_tags
    if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    # if selected_love_location.length > 0 then match.sublove = $all:selected_love_location
    # if selected_love_authors.length > 0 then match.author = $all:selected_love_authors
    # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    love_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    love_tag_cloud.forEach (tag, i) ->
        # console.log tag
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'love_tag'
    
    
    # love_domain_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "data.domain": 1 }
    #     # { $unwind: "$domain" }
    #     { $group: _id: "$data.domain", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_domains }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:10 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # love_domain_cloud.forEach (domain, i) ->
    #     self.added 'results', Random.id(),
    #         name: domain.name
    #         count: domain.count
    #         model:'love_domain_tag'
    
    
    love_location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        { $unwind: "$location_tags" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        # { $match: _id: $nin: selected_location }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    love_location_cloud.forEach (location, i) ->
        self.added 'results', Random.id(),
            name: location.name
            count: location.count
            model:'love_location_tag'
    
    
    
    love_author_cloud = Docs.aggregate [
        { $match: match }
        { $project: "author_tags": 1 }
        { $unwind: "$author_tags" }
        { $group: _id: "$author_tags", count: $sum: 1 }
        { $match: _id: $nin: selected_author_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    love_author_cloud.forEach (author_tag, i) ->
        self.added 'results', Random.id(),
            name: author_tag.name
            count: author_tag.count
            model:'love_author_tag'
  
    self.ready()
        