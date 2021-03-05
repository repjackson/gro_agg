@Docs = new Meteor.Collection 'docs'
@results = new Meteor.Collection 'results'
# @Tag_results = new Meteor.Collection 'tag_results'


Meteor.methods
    log_view: (doc_id)->
        doc = Docs.findOne doc_id
        # console.log 'logging view', doc_id
        Docs.update doc_id, 
            $inc:views:1


Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    doc._app = 'dao'

    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # doc.points = 0
    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        doc.timestamp_tags = date_array
    return
    
    
Docs.helpers
    when: -> moment(@_timestamp).fromNow()
    seven_tags: ->
        if @tags
            @tags[..7]
    five_tags: ->
        if @tags
            @tags[..5]
    ten_tags: ->
        if @tags
            @tags[..10]
    three_tags: ->
        if @tags
            @tags[..3]

    _author: -> Meteor.users.findOne @_author_id
    _buyer: -> Meteor.users.findOne @buyer_id
    target: ->
        Meteor.users.findOne @target_id
    
    is_visible: -> @published in [0,1]
    is_published: -> @published is 1
    is_anonymous: -> @published is 0
    is_private: -> @published is -1
    is_read: ->
        @viewer_ids and Meteor.userId() in @viewer_ids


    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Meteor.users.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Meteor.users.findOne downvoter_id
                downvoters.push downvoter
            downvoters    
            
            
            

Meteor.methods
    upvote: (doc)->
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $addToSet: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        credit:.02
                        upvotes:1
                        downvotes:-1
                        points:2
                Meteor.users.update Meteor.userId(),
                    $inc:points:1
        
                # Meteor.call 'add_global_karma', ->
                # Session.set('session_clicks', Session.get('session_clicks')+2)
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        credit:-.01
                        upvotes:-1
                        points:-1
                Meteor.users.update Meteor.userId(),
                    $inc:points:1
                # Meteor.call 'add_global_karma', ->
                # Session.set('session_clicks', Session.get('session_clicks')+2)
            else
                Docs.update doc._id,
                    $addToSet: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        points:1
                        upvotes:1
                        credit:.01
                Meteor.users.update Meteor.userId(),
                    $inc:points:1
            Meteor.users.update Meteor.userId(),
                $inc:points:1
            Meteor.users.update doc._author_id,
                $inc:points:1
            # Meteor.call 'add_global_karma', ->
            # Session.set('session_clicks', Session.get('session_clicks')+2)
        else
            Docs.update doc._id,
                $inc:
                    anon_credit:.01
                    anon_upvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_points:1
            Meteor.users.update Meteor.userId(),
                $inc:points:1
            # Meteor.call 'add_global_karma', ->
            # Session.set('session_clicks', Session.get('session_clicks')+2)
        found_bounty = Docs.findOne
            model:'bounty'
            status:$ne:'complete'
            require_vote:true
            vote_requirement_met:$ne:true
            target_id:Meteor.userId()
        if found_bounty
            Docs.update found_bounty._id,
                $set:vote_requirement_met: true
            if Meteor.isClient
                $('body').toast({
                    class: 'success',
                    message: "vote requirement met"
                })

    downvote: (doc)->
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $addToSet: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        credit:-.02
                        points:-2
                        downvotes:1
                        upvotes:-1
                Meteor.users.update Meteor.userId(),
                    $inc:points:1
                # Meteor.call 'add_global_karma', ->
                # Session.set('session_clicks', Session.get('session_clicks')+2)
                    
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        points:1
                        credit:.01
                        downvotes:-1
                Meteor.users.update Meteor.userId(),
                    $inc:points:1
                # Meteor.call 'add_global_karma', ->
                # Session.set('session_clicks', Session.get('session_clicks')+2)
                    
            else
                Docs.update doc._id,
                    $addToSet: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        points:-1
                        credit:-.01
                        downvotes:1
                Meteor.users.update Meteor.userId(),
                    $inc:points:1
            Meteor.users.update doc._author_id,
                $inc:points:-1
            # Meteor.call 'add_global_karma', ->
            # Session.set('session_clicks', Session.get('session_clicks')+2)
                
        else
            Docs.update doc._id,
                $inc:
                    anon_credit:-1
                    anon_downvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_points:-1
            # Meteor.call 'add_global_karma', ->
            # Session.set('session_clicks', Session.get('session_clicks')+2)
        found_bounty = Docs.findOne
            model:'bounty'
            status:$ne:'complete'
            require_vote:true
            vote_requirement_met:$ne:true
            target_id:Meteor.userId()
        if found_bounty
            Docs.update found_bounty._id,
                $set:
                    vote_requirement_met: true
            if Meteor.isClient
                $('body').toast({
                    class: 'success',
                    message: "vote requirement met"
                })
