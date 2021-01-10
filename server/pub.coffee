# Meteor.publish 'model_count', (
#     model
#     )->
#     match = {model:model}
    
#     Counts.publish this, 'model_counter', Docs.find(match)
#     return undefined

Meteor.publish 'wikis', (
    w_query
    selected_tags
    )->
    Docs.find({
        model:'wikipedia'
    },{ 
        limit:10
    })
    
    
Meteor.publish 'question_from_id', (site,qid)->
    Docs.find 
        model:'stack_question'
        site:site
        question_id:parseInt(qid)

Meteor.publish 'suser_b', (site,user_id)->
    Docs.find { 
        model:'stack_badge'
        site:site
        "user.user_id":parseInt(user_id)
    }, limit:10
Meteor.publish 'suser_c', (site,user_id)->
    Docs.find { 
        model:'stack_comment'
        site:site
        "owner.user_id":parseInt(user_id)
    }, limit:100
Meteor.publish 'suser_q', (site,user_id)->
    Docs.find { 
        model:'stack_question'
        site:site
        "owner.user_id":parseInt(user_id)
    }, {
        limit:10
        sort:
            score:-1
    }
Meteor.publish 'suser_a', (site,user_id)->
    Docs.find { 
        model:'stack_answer'
        "owner.user_id":parseInt(user_id)
        site:site
    }, limit:10
Meteor.publish 'suser_t', (site,user_id)->
    Docs.find { 
        model:'stack_tag'
        site:site
        "owner.user_id":parseInt(user_id)
    }, limit:10
Meteor.publish 'qid', (site,qid)->
    Docs.find 
        model:'stack_question'
        question_id:parseInt(qid)
        site:site
Meteor.publish 'q_c', (site,qid)->
    cur = Docs.find 
        model:'stack_comment'
        post_id:parseInt(qid)
        site:site
    cur
# Meteor.publish 'question_linked_to', (site,qid)->
#     q = Docs.findOne 
#         model:'stack_question'
#         question_id:parseInt(qid)
#         site:site
#     Docs.find 
#         model:'stack_question'
#         linked_to_ids:$in:[q._id]
#         site:site

# Meteor.publish 'related_questions', (site,qid)->
#     q = Docs.findOne 
#         model:'stack_question'
#         question_id:parseInt(qid)
#         site:site
#     Docs.find 
#         model:'stack_question'
#         _id:$in:q.related_question_ids
#         site:q.site

# Meteor.publish 'linked_questions', (site,qid)->
#     q = Docs.findOne 
#         model:'stack_question'
#         question_id:parseInt(qid)
#         site:site
#     Docs.find 
#         model:'stack_question'
#         _id:$in:q.linked_question_ids
#         site:q.site

Meteor.publish 'current_doc', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id




Meteor.publish 'doc', (doc_id)->
    found_doc = Docs.findOne doc_id
    if found_doc
        Docs.find doc_id
    else
        Meteor.users.find doc_id

Meteor.publish 'model_docs', (model)->
    # console.log 'pulling doc'
    match = {model:model}
    # if Meteor.user()
    #     unless Meteor.user().roles and 'admin' in Meteor.user().roles
    #         match.app = 'stand'
    # else
        # match.app = 'stand'
    Docs.find match


Meteor.publish 'tag_results', (
    # doc_id
    selected_tags
    searching
    query
    dummy
    )->
    # console.log 'dummy', dummy
    console.log 'selected tags', selected_tags
    console.log 'query', query

    self = @
    match = {}

    match.model = $in: ['debit']
    # console.log 'query length', query.length
    # if query
    # if query and query.length > 1
    if query.length > 1
        console.log 'searching query', query
        # #     # match.tags = {$regex:"#{query}", $options: 'i'}
        # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        # #
        terms = Terms.find({
            # title: {$regex:"#{query}"}
            title: {$regex:"#{query}", $options: 'i'}
            app:'stand'
        },
            sort:
                count: -1
            limit: 5
        )
        # console.log terms.fetch()
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: selected_tags }
        #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 42 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]

    else
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


        # debit = Docs.findOne doc_id
        if selected_tags.length > 0
            # match.tags = $all: debit.tags
            match.tags = $all: selected_tags
            # else
            #     # unless selected_domains.length > 0
            #     #     unless selected_subreddits.length > 0
            #     #         unless selected_subreddits.length > 0
            #     #             unless selected_emotions.length > 0
            #     match.tags = $all: ['dao']
            # console.log 'match for tags', match
            # if selected_subreddits.length > 0
            #     match.subreddit = $all: selected_subreddits
            # if selected_domains.length > 0
            #     match.domain = $all: selected_domains
            # if selected_emotions.length > 0
            #     match.max_emotion_name = $all: selected_emotions
            console.log 'match for tags', match
    
    
            agg_doc_count = Docs.find(match).count()
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: "tags": 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                { $match: _id: $nin: selected_tags }
                { $match: count: $lt: agg_doc_count }
                # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }
    
            tag_cloud.forEach (tag, i) =>
                # console.log 'queried tag ', tag
                # console.log 'key', key
                self.added 'tags', Random.id(),
                    title: tag.name
                    count: tag.count
                    # category:key
                    # index: i
            # console.log doc_tag_cloud.count()

        self.ready()

Meteor.publish 'doc_results', (
    selected_tags
    selected_subreddits
    selected_domains
    selected_authors
    selected_emotions
    date_setting
    )->
    # console.log 'got selected tags', selected_tags
    # else
    self = @
    match = {model:$in:['reddit','wikipedia']}
    # if selected_tags.length > 0
    # console.log date_setting
    if date_setting
        if date_setting is 'today'
            now = Date.now()
            day = 24*60*60*1000
            yesterday = now-day
            # console.log yesterday
            match._timestamp = $gt:yesterday

    if selected_tags.length > 0
        # if selected_tags.length is 1
        #     console.log 'looking single doc', selected_tags[0]
        #     found_doc = Docs.findOne(title:selected_tags[0])
        #
        #     match.title = selected_tags[0]
        # else
        match.tags = $all: selected_tags
    else
        # unless selected_domains.length > 0
        #     unless selected_subreddits.length > 0
        #         unless selected_subreddits.length > 0
        #             unless selected_emotions.length > 0
        match.tags = $all: ['dao']
    if selected_domains.length > 0
        match.domain = $all: selected_domains

    if selected_subreddits.length > 0
        match.subreddit = $all: selected_subreddits
    if selected_emotions.length > 0
        match.max_emotion_name = $all: selected_emotions

    # else
    #     match.tags = $nin: ['wikipedia']
    #     sort = '_timestamp'
    #     # match. = $ne:'wikipedia'
    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:
            points:-1
            ups:-1
        limit:10