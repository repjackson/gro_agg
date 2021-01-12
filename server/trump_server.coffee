Meteor.methods 
    trump:->
        imported = JSON.parse(Assets.getText("trump.json"));
        for tweet in imported[15000..18000]
            # console.log tweet
            found = 
                Docs.findOne 
                    model:'trump'
                    id:tweet.id
            if found 
                console.log 'found', found.text
            unless found
                ob = tweet
                ob.model = 'trump'
            
                Docs.insert ob
            
Meteor.publish 'trump_count', (
    selected_tags
    selected_trump_time_tags
    )->
        
    match = {model:'trump'}
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    if selected_trump_time_tags.length > 0 then match.time_tags = $all:selected_trump_time_tags
    Counts.publish this, 'trump_counter', Docs.find(match)
    return undefined
            
Meteor.publish 'trump_docs', (
    selected_trump_tags
    selected_trump_time_tags
    sort_key
    sort_direction
    skip=0
    )->
    self = @
    match = {
        model:'trump'
    }
    if sort_key
        sk = sort_key
    else
        sk = 'date'
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if selected_trump_tags.length > 0 then match.tags = $all:selected_trump_tags
    if selected_trump_time_tags.length > 0 then match.time_tags = $all:selected_trump_time_tags
    # if selected_subtrump_domains.length > 0 then match.domain = $all:selected_subtrump_domains
    # if selected_trump_subtrumps.length > 0 then match.subtrump = $all:selected_trump_subtrumps
    # if selected_trump_authors.length > 0 then match.author = $all:selected_trump_authors
    console.log 'skip', skip
    Docs.find match,
        limit:20
        sort: "#{sk}":-1
        skip:skip*20
    
    
Meteor.methods    
    tagify_trump: (doc_id)->
        doc = Docs.findOne doc_id
        # moment(doc.date).fromNow()
        # timestamp = Date.now()

        doc._timestamp_long = moment(doc.date).format("dddd, MMMM Do YYYY, h:mm:ss a")
        # doc._app = 'dao'
    
        date = moment(doc.date).format('Do')
        weekdaynum = moment(doc.date).isoWeekday()
        weekday = moment().isoWeekday(weekdaynum).format('dddd')
    
        hour = moment(doc.date).format('h')
        minute = moment(doc.date).format('m')
        ap = moment(doc.date).format('a')
        month = moment(doc.date).format('MMMM')
        year = moment(doc.date).format('YYYY')
    
        # doc.points = 0
        # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
        date_array = [ap, weekday, month, date, year]
        if _
            date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
            doc._timestamp_tags = date_array
            # console.log 'trump', date_array
            Docs.update doc_id, 
                $set:time_tags:date_array
    
           
Meteor.publish 'trump_tags', (
    selected_trump_tags
    selected_subtrump_domain
    selected_trump_time_tags
    selected_trump_subtrumps
    selected_trump_authors
    # view_bounties
    # view_unanswered
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'trump'
        # subtrump:subtrump
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if selected_trump_tags.length > 0 then match.tags = $all:selected_trump_tags
    # if selected_subtrump_domain.length > 0 then match.domain = $all:selected_subtrump_domain
    if selected_trump_time_tags.length > 0 then match.time_tags = $all:selected_trump_time_tags
    # if selected_trump_subtrumps.length > 0 then match.subtrump = $all:selected_trump_subtrumps
    # if selected_trump_authors.length > 0 then match.author = $all:selected_trump_authors
    # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    trump_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_trump_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    trump_tag_cloud.forEach (tag, i) ->
        # console.log tag
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'trump_tag'
    
    
    # trump_domain_cloud = Docs.aggregate [
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
    # trump_domain_cloud.forEach (domain, i) ->
    #     self.added 'results', Random.id(),
    #         name: domain.name
    #         count: domain.count
    #         model:'trump_domain_tag'
    
    
    # trump_subtrumps_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "data.subtrump": 1 }
    #     # { $unwind: "$subtrump" }
    #     { $group: _id: "$data.subtrump", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_subtrumps }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:20 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # trump_subtrumps_cloud.forEach (subtrump, i) ->
    #     self.added 'results', Random.id(),
    #         name: subtrump.name
    #         count: subtrump.count
    #         model:'trump_subtrump'
    
    
    
    trump_time_cloud = Docs.aggregate [
        { $match: match }
        { $project: "time_tags": 1 }
        { $unwind: "$time_tags" }
        { $group: _id: "$time_tags", count: $sum: 1 }
        { $match: _id: $nin: selected_trump_time_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    trump_time_cloud.forEach (time_tag, i) ->
        self.added 'results', Random.id(),
            name: time_tag.name
            count: time_tag.count
            model:'trump_time_tag'
  
    self.ready()
                