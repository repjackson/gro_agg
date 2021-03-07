

Meteor.publish 'wiki_doc', (
    # doc_id
    picked_tags
    )->
    # console.log 'dummy', dummy
    # console.log 'publishing wiki doc', picked_tags

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
            "watson.analyzed_text":1
            "watson.metadata":1
            tags:1
            model:1

Meteor.publish 'doc_results', (
    picked_tags
    selected_subreddits
    selected_domains
    selected_authors
    selected_emotions
    date_setting
    )->
    # console.log 'got selected tags', picked_tags
    # else
    self = @
    match = {model:$in:['reddit','wikipedia']}
    # if picked_tags.length > 0
    # console.log date_setting
    if date_setting
        if date_setting is 'today'
            now = Date.now()
            day = 24*60*60*1000
            yesterday = now-day
            # console.log yesterday
            match._timestamp = $gt:yesterday

    if picked_tags.length > 0
        # if picked_tags.length is 1
        #     console.log 'looking single doc', picked_tags[0]
        #     found_doc = Docs.findOne(title:picked_tags[0])
        #
        #     match.title = picked_tags[0]
        # else
        match.tags = $all: picked_tags
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
