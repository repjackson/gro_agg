Meteor.publish 'rpost_comment_tags', (
    subreddit
    parent_id
    picked_tags
    # view_bounties
    # view_unanswered
    # query=''
    )->
    @unblock()
    
    parent = Docs.findOne parent_id
    
    self = @
    match = {
        model:'rcomment'
        parent_id:"t3_#{parent.reddit_id}"
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    # if picked_tags.length > 0 then match.tags = $all:picked_tags
    # if picked_emotion.length > 0 then match.max_emotion_name = picked_emotion
    doc_count = Docs.find(match).count()
    rpost_comment_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:11 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    rpost_comment_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'rpost_comment_tag'
            
    self.ready()
Meteor.publish 'related_posts', (post_id)->
    post = Docs.findOne post_id
    @unblock()

    related_cur = 
        Docs.find({
            model:'rpost'
            subreddit:post.subreddit
            tags:$in:post.tags
            _id:$ne:post._id
        },{ 
            limit:10
            sort:"data.ups":-1
        })
    related_cur
    
            
Meteor.publish 'rpost_comments', (subreddit, doc_id)->
    @unblock()
    
    post = Docs.findOne doc_id
    Docs.find {
        model:'rcomment'
        parent_id:"t3_#{post.reddit_id}"
    }, 
        limit:100
        sort:
            'data.score':-1
        
    
    
Meteor.methods
    tagify_time_rpost: (doc_id)->
        doc = Docs.findOne doc_id
        # moment.unix(doc.data.created).fromNow()
        # timestamp = Date.now()

        doc._timestamp_long = moment.unix(doc.data.created).format("dddd, MMMM Do YYYY, h:mm:ss a")
        # doc._app = 'dao'
    
        date = moment.unix(doc.data.created).format('Do')
        weekdaynum = moment.unix(doc.data.created).isoWeekday()
        weekday = moment().isoWeekday(weekdaynum).format('dddd')
    
        hour = moment.unix(doc.data.created).format('h')
        minute = moment.unix(doc.data.created).format('m')
        ap = moment.unix(doc.data.created).format('a')
        month = moment.unix(doc.data.created).format('MMMM')
        year = moment.unix(doc.data.created).format('YYYY')
    
        # doc.points = 0
        # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
        date_array = [ap, weekday, month, date, year]
        if _
            date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
            doc._timestamp_tags = date_array
            Docs.update doc_id, 
                $set:time_tags:date_array
                        
