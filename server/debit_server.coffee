Meteor.publish 'gift_tag_results', (
    selected_tags
    selected_location_tags
    selected_authors
    )->
    # console.log 'dummy', dummy
    console.log 'selected tags', selected_tags
    # console.log 'query', query

    self = @
    match = {}

    match.model = 'gift'
    # console.log 'query length', query.length
    # if query
    # if query and query.length > 1
    # unless query and query.length > 2
    # if selected_tags.length > 0 then match.tags = $all: selected_tags
    # console.log date_setting
    # if date_setting
    #     if date_setting is 'today'
    #         now = Date.now()
    #         day = 24*60*60*1000
    #         yesterday = now-day
    #         console.log yesterday
    #         match._timestamp = $gt:yesterday


    if selected_tags.length > 0
        match.tags = $all: selected_tags
    console.log 'match for gift tags', match


    # agg_doc_count = Docs.find(match).count()
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        # { $match: count: $lt: agg_doc_count }
        # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    tag_cloud.forEach (tag, i) =>
        console.log 'queried tag ', tag
        self.added 'tags', Random.id(),
            title: tag.name
            count: tag.count
            # category:key
            # index: i
    # console.log doc_tag_cloud.count()

    # # agg_doc_count = Docs.find(match).count()
    location_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        # { $unwind: "$location_tag" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        { $match: _id: $nin: selected_location_tags }
        # { $match: count: $lt: agg_doc_count }
        # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    location_tag_cloud.forEach (location_tag, i) =>
        # console.log 'queried location_tag ', location_tag
        # console.log 'key', key
        self.added 'location_tag_results', Random.id(),
            title: location_tag.name
            count: location_tag.count
            # category:key
            # index: i
    # console.log doc_tag_cloud.count()


    self.ready()

Meteor.publish 'gift_results', (
    selected_tags
    selected_location_tags=[]
    selected_authors=[]
    # date_setting
    )->
    # console.log 'got selected tags', selected_tags
    # else
    self = @
    match = {model:'gift'}
    # if selected_tags.length > 0
    # console.log date_setting
    # if date_setting
    #     if date_setting is 'today'
    #         now = Date.now()
    #         day = 24*60*60*1000
    #         yesterday = now-day
    #         # console.log yesterday
    #         match._timestamp = $gt:yesterday

    if selected_tags.length > 0
        # if selected_tags.length is 1
        #     console.log 'looking single doc', selected_tags[0]
        #     found_doc = Docs.findOne(title:selected_tags[0])
        #
        #     match.title = selected_tags[0]
        # else
        match.tags = $all: selected_tags
    if selected_location_tags.length > 0
        match.location_tags = $all: selected_location_tags

    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:
            points:-1
            ups:-1
        limit:10
        
Meteor.methods
    # calc_user_stats: (user_id)->
    #     user = Meteor.users.findOne user_id
    #     gift_count =
    #         Docs.find(
    #             model:'gift'
    #             _author_id: user_id
    #         ).count()

    #     credit_count =
    #         Docs.find(
    #             model:'gift'
    #             target_id: user_id
    #         ).count()

    #     Meteor.users.update user_id,
    #         $set:
    #             gift_count:gift_count
    #             credit_count:credit_count


    #     gift_count_ranking =
    #         Meteor.users.find(
    #             {},
    #             sort:
    #                 gift_count: -1
    #             fields:
    #                 username: 1
    #         ).fetch()
    #     gift_count_ranking_ids = _.pluck gift_count_ranking, '_id'

    #     # console.log 'gift_count_ranking', gift_count_ranking
    #     # console.log 'gift_count_ranking ids', gift_count_ranking_ids
    #     my_rank = _.indexOf(gift_count_ranking_ids, user_id)+1
    #     console.log 'my rank', my_rank
    #     Meteor.users.update user_id,
    #         $set:
    #             global_gift_count_rank:my_rank


    #     credit_count_ranking =
    #         Meteor.users.find(
    #             {},
    #             sort:
    #                 credit_count: -1
    #             fields:
    #                 username: 1
    #         ).fetch()
    #     credit_count_ranking_ids = _.pluck credit_count_ranking, '_id'

    #     # console.log 'credit_count_ranking', credit_count_ranking
    #     # console.log 'credit_count_ranking ids', credit_count_ranking_ids
    #     my_rank = _.indexOf(credit_count_ranking_ids, user_id)+1
    #     console.log 'my rank', my_rank
    #     Meteor.users.update user_id,
    #         $set:
    #             global_credit_count_rank:my_rank


    # calc_user_points: (user_id)->
    #     user = Meteor.users.findOne user_id
    #     debits = Docs.find({
    #         model:'debit'
    #         amount:$exists:true
    #         _author_id:user_id})
    #     debit_count = debits.count()
    #     total_debit_amount = 0
    #     for debit in debits.fetch()
    #         total_debit_amount += debit.amount

    #     console.log 'total debit amount', total_debit_amount

    #     credits = Docs.find({
    #         model:'debit'
    #         amount:$exists:true
    #         target_id:user_id})
    #     credit_count = credits.count()
    #     total_credit_amount = 0
    #     for credit in credits.fetch()
    #         total_credit_amount += credit.amount

    #     console.log 'total credit amount', total_credit_amount
    #     calculated_user_balance = total_credit_amount-total_debit_amount

    #     Meteor.users.update user_id,
    #         $set:
    #             points:calculated_user_balance
    #             total_credit_amount: total_credit_amount
    #             total_debit_amount: total_debit_amount







    calc_global_stats: ()->
        gs = Docs.findOne model:'global_stats'
        unless gs 
            Docs.insert 
                model:'global_stats'
        gs = Docs.findOne model:'global_stats'
        
        total_points = 0
        
        point_users = 
            Meteor.users.find 
                points: $exists:true
        for point_user in point_users.fetch()
            total_points += point_user.points
    
        console.log 'total points', total_points
        Docs.update gs._id,
            $set:total_points:total_points        