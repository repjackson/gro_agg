Meteor.publish 'love_count', (
    picked_tags
    picked_authors
    picked_location_tags
    picked_time_tags
    picked_l
    picked_o
    picked_v
    picked_e
    )->
    match = {model:'love'}
        
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_authors.length > 0 then match.author_tags = $all:picked_authors
    if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if picked_l.length > 0 then match.l_value = $all:picked_l
    if picked_o.length > 0 then match.o_value = $all:picked_o
    if picked_v.length > 0 then match.v_value = $all:picked_v
    if picked_e.length > 0 then match.e_value = $all:picked_e

    Counts.publish this, 'counter', Docs.find(match)
    return undefined
            
Meteor.publish 'expressions', (
    picked_tags
    picked_time_tags
    picked_location_tags
    picked_authors
    picked_l
    picked_o
    picked_v
    picked_e
    sort_key
    sort_direction
    skip=0
    )->
    self = @
    match = {
        model:'love'
    }
    if sort_key
        sk = sort_key
    else
        sk = '_timestamp'
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    # if picked_authors.length > 0 then match.author_tags = $all:picked_authors
    if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags
    if picked_authors.length > 0 then match.author = $all:picked_authors
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if picked_l.length > 0 then match.l_value = $all:picked_l
    if picked_o.length > 0 then match.o_value = $all:picked_o
    if picked_v.length > 0 then match.v_value = $all:picked_v
    if picked_e.length > 0 then match.e_value = $all:picked_e

    
    Docs.find match,
        limit:100
        sort:_timestamp:-1
        # sort: "#{sk}":-1
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
    picked_tags
    picked_authors
    picked_location_tags
    picked_time_tags
    picked_l
    picked_o
    picked_v
    picked_e
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'love'
        # love:love
        # sublove:sublove
    }

    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_authors.length > 0 then match.author_tags = $all:picked_authors
    if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    if picked_l.length > 0 then match.l_value = $all:picked_l
    if picked_o.length > 0 then match.o_value = $all:picked_o
    if picked_v.length > 0 then match.v_value = $all:picked_v
    if picked_e.length > 0 then match.e_value = $all:picked_e
    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    love_tag_cloud = Docs.aggregate [
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
    #     # { $match: _id: $nin: picked_domains }
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
        # { $match: _id: $nin: picked_location }
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
        { $match: _id: $nin: picked_authors }
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
    
    
    l_cloud = Docs.aggregate [
        { $match: match }
        { $project: "l_value": 1 }
        { $group: _id: "$l_value", count: $sum: 1 }
        { $match: _id: $nin: picked_l }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    l_cloud.forEach (l_tag, i) ->
        self.added 'results', Random.id(),
            name: l_tag.name
            count: l_tag.count
            model:'l_tag'
  
    o_cloud = Docs.aggregate [
        { $match: match }
        { $project: "o_value": 1 }
        { $group: _id: "$o_value", count: $sum: 1 }
        { $match: _id: $nin: picked_l }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    o_cloud.forEach (l_tag, i) ->
        self.added 'results', Random.id(),
            name: l_tag.name
            count: l_tag.count
            model:'o_tag'
  
    v_cloud = Docs.aggregate [
        { $match: match }
        { $project: "v_value": 1 }
        { $group: _id: "$v_value", count: $sum: 1 }
        { $match: _id: $nin: picked_l }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    v_cloud.forEach (v_tag, i) ->
        self.added 'results', Random.id(),
            name: v_tag.name
            count: v_tag.count
            model:'v_tag'
  
    love_e_cloud = Docs.aggregate [
        { $match: match }
        { $project: "e_value": 1 }
        { $group: _id: "$e_value", count: $sum: 1 }
        { $match: _id: $nin: picked_l }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    love_e_cloud.forEach (e_tag, i) ->
        self.added 'results', Random.id(),
            name: e_tag.name
            count: e_tag.count
            model:'e_tag'
  
    self.ready()
        