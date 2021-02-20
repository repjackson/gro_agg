if Meteor.isClient
    Router.route '/u/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/u/:username/comments', (->
        @layout 'profile_layout'
        @render 'user_comments'
        ), name:'user_comments'
    Router.route '/u/:username/posts', (->
        @layout 'profile_layout'
        @render 'user_posts'
        ), name:'user_posts'
    Router.route '/u/:username/tips', (->
        @layout 'profile_layout'
        @render 'user_tips'
        ), name:'user_tips'

    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'user_posts', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_commentss', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_debits', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_checkins', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_child_referrals', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_requests', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_completed_requests', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_event_tickets', Router.current().params.username
        # @autorun -> Meteor.subscribe 'model_docs', 'event'
        # @autorun -> Meteor.subscribe 'all_users'
        
    Template.user_dashboard.events
        'click .user_credit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
        'click .user_debit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
        'click .user_checkin_segment': ->
            Router.go "/drink/#{@drink_id}/view"
            
            
            
    Template.user_dashboard.helpers
        user_referred: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.users.find 
                referrer:current_user._id
        user_comments: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'comment'
                _author_id: current_user._id
            }, 
                limit: 10
                sort: _timestamp:-1
        user_debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
            }, 
                limit: 10
                sort: _timestamp:-1
        user_credits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                recipient_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                _author_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_completed_requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                completed_by_user_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_event_tickets: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                transaction_type:'ticket_purchase'
            }, 
                sort: _timestamp:-1
                limit: 10


        
        
    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
    
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.no_blink')
                .popup()
        , 1000
        user = Meteor.users.findOne(username:Router.current().params.username)
        Meteor.setTimeout ->
            if user
                Meteor.call 'calc_user_stats', user._id, ->
                Meteor.call 'log_user_view', user._id, ->
        , 2000


    Template.profile_layout.helpers
        route_slug: -> "user_#{@slug}"
        user: -> Meteor.users.findOne username:Router.current().params.username

    Template.user_dashboard.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
        @autorun => Meteor.subscribe('model_docs', 'group_bookmark')

    Template.user_dashboard.helpers
        group_bookmarks: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'group_bookmark'
                _author_id:user._id
            }, sort:search_amount:-1
        posts: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'post'
                _author_id:user._id
            }, sort:search_amount:-1
        tips: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'tip'
                _author_id:user._id
            }, sort:amount:-1
                
        reflections: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'reflections'
                _author_id:user._id
            }, sort:_timestamp:-1
        comments: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'comment'
                _author_id:user._id
            }, sort:_timestamp:-1
                
    Template.profile_layout.events
        'click a.select_term': ->
            $('.profile_yield')
                .transition('fade out', 200)
                .transition('fade in', 200)
        'click .click_group': (e,t)->
            # $('.label')
            #     .transition('fade out', 200)
            Router.go "/g/#{@name}"
        'keyup .goto_group': (e,t)->
            if e.which is 13
                val = $('.goto_group').val()
                found_group =
                    Docs.findOne 
                        model:'group_bookmark'
                        name:val
                if found_group
                    Docs.update found_group._id,
                        $inc:search_amount:1
                else
                    Docs.insert 
                        model:'group_bookmark'
                        search_amount:1
                        name:val
                # $('.header')
                #     .transition('scale', 200)
                # $('.global_container')
                #     .transition('scale', 400)
                Router.go "/g/#{val}"
                # target_user = Meteor.users.findOne(username:Router.current().params.username)
                # Docs.insert
                #     model:'debit'
                #     body: val
                #     target_user_id: target_user._id
        'click .remove_group': ->
            if confirm 'remove group?'
                Docs.remove @_id
        # 'click .goto_users': ->
        #     $('.global_container')
        #         .transition('fade right', 500)
        #         # .transition('fade in', 200)
        #     Meteor.setTimeout ->
        #         Router.go '/users'
        #     , 500
    
    
        'click .refresh_user_stats': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            # Meteor.call 'calc_user_stats', user._id, ->
            Meteor.call 'recalc_user_stats', user._id, ->
            Meteor.call 'calc_user_tags', user._id, ->
    
    Template.profile_layout.events
        'click .send': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            if Meteor.userId() is user._id
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        amount:1
            else
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        amount:1
                        recipient_id: user._id
            Router.go "/debit/#{new_debit_id}/edit"


        'click .tip': ->
            # user = Meteor.users.findOne(username:@username)
            new_debit_id =
                Docs.insert
                    model:'dollar_debit'
            Router.go "/dollar_debit/#{new_debit_id}/edit"

        # 'click .request': ->
        #     user = Meteor.users.findOne(username:@username)
        #     if Meteor.userId() is user._id
        #         new_id =
        #             Docs.insert
        #                 model:'request'
        #                 amount:1
        #     else    
        #         new_id =
        #             Docs.insert
        #                 model:'request'
        #                 recipient_id: user._id
        #                 amount:1
        #     Router.go "/request/#{new_id}/edit"
    
        # 'click .recalc_user_cloud': ->
        #     Meteor.call 'recalc_user_cloud', Router.current().params.username, ->

        'click .logout': ->
            # Router.go '/login'
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false





if Meteor.isServer
    Meteor.methods
        log_user_view: (user_id)->
            if Meteor.user()
                unless user_id is Meteor.userId()
                    Meteor.users.update user_id,
                        $inc:profile_views:1
            
        # calc_test_sessions: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     now = Date.now()
        #     console.log now
        #     past_24_hours = now-(24*60*60*1000)
        #     past_week = now-(7*24*60*60*1000)
        #     past_month = now-(30*7*24*60*60*1000)
        #     console.log past_24_hours
        #     all_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             }).count()
        #     todays_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_24_hours
        #             }).count()
        #     weeks_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_week
        #             }).count()
        #     months_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_month
        #             }).count()
        #     console.log 'all session count', all_sessions_count
        #     console.log 'today sessions count', todays_sessions_count
        #     Meteor.users.update user_id,
        #         $set:
        #             all_sessions_count:all_sessions_count
        #             todays_sessions_count: todays_sessions_count
        #             weeks_sessions_count: weeks_sessions_count
        #             months_sessions_count: months_sessions_count

        #     # this_week = moment().startOf('isoWeek')
        #     # this_week = moment().startOf('isoWeek')


        # recalc_user_act_stats: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     test_session_cursor =
        #         Docs.find
        #             model:'test_session'
        #             _author_id: user_id
        #     site_test_cursor =
        #         Docs.find(
        #             model:'test'
        #         )
        #     site_test_count = site_test_cursor.count()
        #     answered_tests = 0
        #     for test in site_test_cursor.fetch()
        #         user_test_session =
        #             Docs.findOne
        #                 model:'test_session'
        #                 test_id: test._id
        #                 _author_id:username
        #         if user_test_session
        #             answered_tests++
        #     console.log 'answered tests', answered_tests
        #     global_section_percent = 0

        #     session_count = test_session_cursor.count()
        #     for section in ['english', 'math', 'science', 'reading']
        #         section_test_cursor =
        #             Docs.find {
        #                 model:'test'
        #                 tags: $in: [section]
        #             }
        #         section_count = section_test_cursor.count()
        #         section_tests = section_test_cursor.fetch()
        #         section_test_ids = []
        #         for section_test in section_tests
        #             section_test_ids.push section_test._id

        #         # console.log section
        #         # console.log section_test_ids
        #         user_section_test_sessions =
        #             Docs.find {
        #                 model:'test_session'
        #                 test_id: $in: section_test_ids
        #                 _author_id: user_id
        #             }
        #         # console.log user_section_test_sessions.fetch()
        #         user_section_test_session_count = user_section_test_sessions.count()
        #         total_section_average = 0
        #         for test_session in user_section_test_sessions.fetch()
        #             if test_session.correct_percent
        #                 total_section_average += parseInt(test_session.correct_percent)
        #         user_section_average = total_section_average/user_section_test_session_count
        #         # console.log 'user section average', section, user_section_average
        #         if user_section_average
        #             Meteor.users.update user_id,
        #                 $set:
        #                     "#{section}_average": user_section_average.toFixed()
        #             global_section_percent += user_section_average
        #         else
        #             Meteor.users.update user_id,
        #                 $set:
        #                     "#{section}_average": 0
        #     site_percent_complete = parseInt((answered_tests/site_test_count)*100)
        #     global_section_average = global_section_percent/4



        #     Meteor.users.update user_id,
        #         $set:
        #             session_count:session_count
        #             site_percent_complete:site_percent_complete
        #             global_section_average:global_section_average.toFixed()


        #     section_average_ranking =
        #         Meteor.users.find(
        #             {},
        #             sort:
        #                 global_section_average: -1
        #             fields:
        #                 username: 1
        #         ).fetch()
        #     section_average_ranking_ids = _.pluck section_average_ranking, '_id'

        #     console.log 'section average ranking', section_average_ranking
        #     console.log 'section average ranking ids', section_average_ranking_ids
        #     my_rank = _.indexOf(section_average_ranking_ids, user_id)+1
        #     console.log 'my rank', my_rank
        #     Meteor.users.update user_id,
        #         $set:
        #             global_section_average_rank:my_rank


        #     # average_english_percent
        #     # average_math_percent
        #     # average_science_percent
        #     # average_reading_percent


        # recalc_user_cloud: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     test_session_cursor =
        #         Docs.find
        #             model:'test_session'
        #             _author_id: user_id
        #             right_tags: $exists: true
        #     all_right_tags = []
        #     all_wrong_tags = []
        #     right_tag_list = []
        #     wrong_tag_list = []
        #     right_tag_cloud = []
        #     wrong_tag_cloud = []

        #     for test_session in test_session_cursor.fetch()
        #         for right_tag in test_session.right_tags
        #             unless right_tag in right_tag_list
        #                 right_tag_list.push right_tag
        #             all_right_tags.push right_tag
        #             tag_object = _.findWhere(right_tag_cloud, {tag: right_tag})
        #             # console.log tag_object
        #             if tag_object
        #                 index_of_tag = _.indexOf(right_tag_cloud, tag_object)
        #                 # console.log 'index of tag', index_of_tag
        #                 tag_count = tag_object.count
        #                 # console.log tag_count
        #                 # console.log 'inc', tag_count++
        #                 right_tag_cloud[index_of_tag] = {
        #                     tag:right_tag
        #                     count:tag_count+1
        #                 }
        #             else
        #                 tag_object = {
        #                     tag:right_tag
        #                     count: 1
        #                 }
        #                 right_tag_cloud.push tag_object
        #         for wrong_tag in test_session.wrong_tags
        #             unless wrong_tag in wrong_tag_list
        #                 wrong_tag_list.push wrong_tag
        #             all_wrong_tags.push wrong_tag
        #             tag_object = _.findWhere(wrong_tag_cloud, {tag: wrong_tag})
        #             # console.log tag_object
        #             if tag_object
        #                 index_of_tag = _.indexOf(wrong_tag_cloud, tag_object)
        #                 # console.log 'index of tag', index_of_tag
        #                 tag_count = tag_object.count
        #                 # console.log tag_count
        #                 # console.log 'inc', tag_count++
        #                 wrong_tag_cloud[index_of_tag] = {
        #                     tag:wrong_tag
        #                     count:tag_count+1
        #                 }
        #             else
        #                 tag_object = {
        #                     tag:wrong_tag
        #                     count: 1
        #                 }
        #                 wrong_tag_cloud.push tag_object
        #     # console.log right_tag_cloud
        #     right_tag_cloud =  _.sortBy(right_tag_cloud, 'count')
        #     wrong_tag_cloud = _.sortBy(wrong_tag_cloud, 'count')
        #     right_tag_cloud = right_tag_cloud.reverse()
        #     wrong_tag_cloud = wrong_tag_cloud.reverse()
        #     right_tag_cloud = right_tag_cloud[..10]
        #     wrong_tag_cloud = wrong_tag_cloud[..10]
        #     # right_tag_cloud = _.countBy(all_right_tags, (tag)-> tag)
        #     # wrong_tag_cloud = _.countBy(all_wrong_tags, (tag)-> tag)

        #     Meteor.users.update user_id,
        #         $set:
        #             right_tag_list:right_tag_list
        #             wrong_tag_list:wrong_tag_list
        #             right_tag_cloud:right_tag_cloud
        #             wrong_tag_cloud:wrong_tag_cloud



        recalc_user_stats: (user_id)->
            user = Meteor.users.findOne user_id
            unless user
                user = Meteor.users.findOne username
            user_id = user._id
            # console.log classroom
            # student_stats_doc = Docs.findOne
            #     model:'student_stats'
            #     user_id: user_id
            #
            # unless student_stats_doc
            #     new_stats_doc_id = Docs.insert
            #         model:'student_stats'
            #         user_id: user_id
            #     student_stats_doc = Docs.findOne new_stats_doc_id

            # debits = Docs.find({
            #     model:'debit'
            #     amount:$exists:true
            #     _author_id:user_id})
            # debit_count = debits.count()
            # total_debit_amount = 0
            # for debit in debits.fetch()
            #     total_debit_amount += debit.amount

            # console.log 'total debit amount', total_debit_amount

            tips_out = Docs.find({
                model:'tip'
                _author_id: user_id
            })
            tips_out_count = tips_out.count()
            console.log 'tips out count', tips_out_count
            
            total_tips_out_amount = 0
            for tip in tips_out.fetch()
                if tip.amount
                    total_tips_out_amount += tip.amount
            
            
            tips_in = Docs.find({
                model:'post'
                _author_id: user_id
                # tip_total: $exists: true
            })
            tips_in_count = tips_in.count()
            console.log 'tips in count', tips_in_count
            
            total_tips_in_amount = 0
            for post in tips_in.fetch()
                if post.tip_total
                    total_tips_in_amount += post.tip_total
            
            
            # posts = Docs.find({
            #     model:'post'
            #     _author_id:user_id
            #     # published:true
            # })
            # post_count = posts.count()
            # total_request_amount = 0
            # for request in requested.fetch()
            #     total_request_amount += request.point_bounty
            
            
            # credits = Docs.find({
            #     model:'debit'
            #     amount:$exists:true
            #     recipient_id:user_id})
            # credit_count = credits.count()
            # total_credit_amount = 0
            # for credit in credits.fetch()
            #     total_credit_amount += credit.amount

            console.log 'total tips in amount', total_tips_in_amount
            console.log 'total tips out amount', total_tips_out_amount
            tip_balance = total_tips_in_amount - total_tips_out_amount
            
            console.log 'total tip balance', tip_balance
            # average_credit_per_student = total_credit_amount/student_count
            # average_debit_per_student = total_debit_amount/student_count
            # flow_volume = Math.abs(total_credit_amount)+Math.abs(total_debit_amount)
            # flow_volumne =+ total_fulfilled_amount
            # flow_volumne =+ total_request_amount
            
            
            # points = total_credit_amount-total_debit_amount+total_fulfilled_amount-total_request_amount
            # points =+ total_fulfilled_amount
            # points =- total_request_amount
            
            # if total_debit_amount is 0 then total_debit_amount++
            # if total_credit_amount is 0 then total_credit_amount++
            # # debit_credit_ratio = total_debit_amount/total_credit_amount
            # unless total_debit_amount is 1
            #     unless total_credit_amount is 1
            #         one_ratio = total_debit_amount/total_credit_amount
            #     else
            #         one_ratio = 0
            # else
            #     one_ratio = 0
                    
            # dc_ratio_inverted = 1/debit_credit_ratio

            # credit_debit_ratio = total_credit_amount/total_debit_amount
            # cd_ratio_inverted = 1/credit_debit_ratio

            # one_score = total_bandwith*dc_ratio_inverted

            Meteor.users.update user_id,
                $set:
                    points:tip_balance
                    # credit_count: credit_count
                    # debit_count: debit_count
                    # total_credit_amount: total_credit_amount
                    # total_debit_amount: total_debit_amount
                    # flow_volume: flow_volume
                    # points:points
                    # one_ratio: one_ratio
                    # total_fulfilled_amount:total_fulfilled_amount
                    # fulfilled_count:fulfilled_count
                    
                    
if Meteor.isServer
    Meteor.publish 'user_child_referrals', (username)->
        user = Meteor.users.findOne username:username
        Meteor.users.find({
            referrer:user._id
            # _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
    Meteor.publish 'user_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'debit'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
    Meteor.publish 'user_posts', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'post'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
    Meteor.publish 'user_comments', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'comment'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        