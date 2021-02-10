Meteor.publish 'love_count', (
    picked_tags
    picked_authors
    picked_locations
    picked_times
    picked_l
    picked_o
    picked_v
    picked_e
    )->
    match = {model:'love'}
        
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_authors.length > 0 then match.author = $all:picked_authors
    if picked_locations.length > 0 then match.location = $all:picked_locations
    if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    if picked_l.length > 0 then match.l_value = $all:picked_l
    if picked_o.length > 0 then match.o_value = $all:picked_o
    if picked_v.length > 0 then match.v_value = $all:picked_v
    if picked_e.length > 0 then match.e_value = $all:picked_e

    Counts.publish this, 'counter', Docs.find(match)
    return undefined
            
Meteor.publish 'expressions', (
    picked_tags
    picked_times
    picked_locations
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
    if picked_locations.length > 0 then match.location = $all:picked_locations
    if picked_authors.length > 0 then match.author = $all:picked_authors
    if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    if picked_l.length > 0 then match.l_value = $all:picked_l
    if picked_o.length > 0 then match.o_value = $all:picked_o
    if picked_v.length > 0 then match.v_value = $all:picked_v
    if picked_e.length > 0 then match.e_value = $all:picked_e

    # console.log 'match',match
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
    #             $set:addedauthors:date_array
    
           
Meteor.publish 'love_tags', (
    picked_tags
    picked_times
    picked_locations
    picked_authors
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
    if picked_authors.length > 0 then match.author = $all:picked_authors
    if picked_locations.length > 0 then match.location = $all:picked_locations
    if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
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
    
    location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location": 1 }
        # { $unwind: "$location" }
        { $group: _id: "$location", count: $sum: 1 }
        # { $match: _id: $nin: picked_location }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    location_cloud.forEach (location, i) ->
        self.added 'results', Random.id(),
            name: location.name
            count: location.count
            model:'location_tag'
    
    
    time_cloud = Docs.aggregate [
        { $match: match }
        { $project: "timestamp_tags": 1 }
        { $unwind: "$timestamp_tags" }
        { $group: _id: "$timestamp_tags", count: $sum: 1 }
        # { $match: _id: $nin: picked_time }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    # console.log match
    time_cloud.forEach (time, i) ->
        # console.log 'time', time
        self.added 'results', Random.id(),
            name: time.name
            count: time.count
            model:'time_tag'
    
    
    
    author_cloud = Docs.aggregate [
        { $match: match }
        { $project: "author": 1 }
        # { $unwind: "$author" }
        { $group: _id: "$author", count: $sum: 1 }
        { $match: _id: $nin: picked_authors }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    author_cloud.forEach (author, i) ->
        self.added 'results', Random.id(),
            name: author.name
            count: author.count
            model:'author'
    
    
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
  
    e_cloud = Docs.aggregate [
        { $match: match }
        { $project: "e_value": 1 }
        { $group: _id: "$e_value", count: $sum: 1 }
        { $match: _id: $nin: picked_l }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:25 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    e_cloud.forEach (e_tag, i) ->
        self.added 'results', Random.id(),
            name: e_tag.name
            count: e_tag.count
            model:'e_tag'
  
    self.ready()
        