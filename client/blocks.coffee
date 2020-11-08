if Meteor.isClient
    # Template.emotion_pick.events
    #     'click .pick': ->
    #         console.log Template.parentData()
    #         Docs.update Template.parentData()._id,
    #             $set:
    #                 emotion:@k

    # Template.emotion_pick.helpers
    #     pick_class: ->
    #         if Template.parentData().emotion is @k then @color else 'grey'

    Template.print_this.events
        'click .print_this': ->
            console.log @
    Template.smart_tagger.onCreated ->
        # @autorun => @subscribe 'tag_results',
        #     # @_id
        #     selected_tags.array()
        #     Session.get('searching')
        #     Session.get('current_query')
        #     Session.get('dummy')

    Template.smart_tagger.helpers        
        # terms: -> Terms.find()
        # suggestions: -> Tag_results.find()

    Template.smart_tagger.events
        'keyup .new_tag': _.throttle((e,t)->
            query = $('.new_tag').val()
            if query.length > 0
                Session.set('searching', true)
            else
                Session.set('searching', false)
            Session.set('current_query', query)
            
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update @_id,
                    $addToSet:tags:element_val
                selected_tags.push element_val
                # Meteor.call 'log_term', element_val, ->
                Session.set('searching', false)
                Session.set('current_query', '')
                Meteor.call 'add_tag', @_id, ->
    
                # Session.set('dummy', !Session.get('dummy'))
                t.$('.new_tag').val('')
        , 250)

        'click .remove_element': (e,t)->
            element = @vOf()
            field = Template.currentData()
            selected_tags.remove element
            Docs.update @_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
            # Session.set('dummy', !Session.get('dummy'))
    
    
        'click .select_term': (e,t)->
            # selected_tags.push @title
            Docs.update @_id,
                $addToSet:tags:@title
            selected_tags.push @title
            $('.new_tag').val('')
            Session.set('current_query', '')
            Session.set('searching', false)
            # Session.set('dummy', !Session.get('dummy'))


    Template.vote.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'author_vote', @data._id

    Template.vote.helpers
        user_vote: ->
            Docs.findOne 
                model:'vote'
                parent_id:@_id
                _author_id:Meteor.userId()
            
    Template.vote.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            # if Meteor.user()
            Meteor.call 'upvote', @_id, ->
            #     Meteor.call 'calc_post_votes', @_id, ->
            # else
            #     Router.go "/register"
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            # if Meteor.user()
            Meteor.call 'downvote', @_id, ->
            # Meteor.call 'calc_post_votes', @_id, ->
            # else
            #     Router.go "/register"




    Template.session_toggle_button.helpers
        session_toggle_button_class: ->
            if Template.instance().subscriptionsReady()
                if Session.get(@k) then 'grey' else 'basic'
            else
                'disabled loading'
    Template.session_toggle_button.events
        'click .toggle': -> Session.set(@k, !Session.get(@k))
#
    Template.comments.onRendered ->
        # Meteor.setTimeout ->
        #     $('.menu .item').tab()
        # , 2000
    Template.comments.onCreated ->
        # if @_id
        #     parent = Docs.findOne @_id
        # else
        #     parent = Docs.findOne Template.parentData()._id
        # if parent
        @autorun => Meteor.subscribe 'children', 'comment', @_id
    Template.comments.helpers
        doc_comments: ->
            if @_id
                parent = Docs.findOne @_id
            else
                parent = Docs.findOne Template.parentData()._id
            if Meteor.user()
                Docs.find
                    parent_id:parent._id
                    model:'comment'
            else
                Docs.find
                    model:'comment'
                    parent_id:parent._id
                    _author_id:$exists:false
                    
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                if @_id
                    parent = Docs.findOne @_id
                else
                    parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne @_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    parent_model:parent.model
                    body:comment
        
                t.$('.add_comment').val('')
                Meteor.call 'calc_user_stats', Meteor.userId(), ->

        'click .remove_comment': ->
            if confirm 'Confirm remove comment'
                Docs.remove @_id

    Template.follow.helpers
        followers: ->
            Meteor.users.find
                _id: $in: @follower_ids
        following: -> @follower_ids and Meteor.userId() in @follower_ids
    Template.follow.events
        'click .follow': ->
            Docs.update @_id,
                $addToSet:follower_ids:Meteor.userId()
        'click .unfollow': ->
            Docs.update @_id,
                $pull:follower_ids:Meteor.userId()


    Template.voting.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            if Meteor.user()
                Meteor.call 'upvote', @, ->
            else
                Router.go "/register"
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            if Meteor.user()
                Meteor.call 'downvote', @, ->
            else
                Router.go "/register"
    Template.voting_small.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->
#
#
#

if Meteor.isServer
    Meteor.methods 
        calc_post_votes: (doc_id)->
            doc = Docs.findOne doc_id
            # console.log 'post', doc
            votes = 
                Docs.find 
                    model:'vote'
                    parent_id:doc_id
            total_doc_points = 0
            for vote in votes.fetch()
                total_doc_points += vote.points
                
            Docs.update doc_id, 
                $set:
                    points:total_doc_points
                    
                    
    Meteor.publish 'author_vote', (parent_id)->
        Docs.find 
            model:'vote'
            parent_id:parent_id


if Meteor.isClient
#     Template.doc_card.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Template.currentData().doc_id
#     Template.doc_card.helpers
#         doc: ->
#             Docs.findOne
#                 _id:Template.currentData().doc_id
#
#
#
#
#
#     # Template.call_watson.events
#     #     'click .autotag': ->
#     #         doc = Docs.findOne @_id
#     #         console.log doc
#     #         console.log @
#     #
#     #         Meteor.call 'call_watson', doc._id, @k, @mode
#
    Template.voting_full.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->


#
#     Template.role_editor.onCreated ->
#         @autorun => Meteor.subscribe 'model', 'role'
#
#
#
#
#     Template.small_horizontal_user_card.onCreated ->
#         @autorun => Meteor.subscribe 'user_from_username', @data
#     Template.small_horizontal_user_card.helpers
#         user: -> Meteor.users.findOne username:@vOf()
#
#
#
#     Template.big_user_card.onCreated ->
#         @autorun => Meteor.subscribe 'user_from_username', @data
#     Template.big_user_card.helpers
#         user: -> Meteor.users.findOne username:@vOf()
#
#
#
#
#     Template.username_info.onCreated ->
#         @autorun => Meteor.subscribe 'user_from_username', @data
#     Template.username_info.events
#         'click .goto_profile': ->
#             user = Meteor.users.findOne username:@vOf()
#             Router.go "/u/#{user.username}/"
#     Template.username_info.helpers
#         user: -> Meteor.users.findOne username:@vOf()
#
#
#

    Template.user_info.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info.helpers
        user: -> Meteor.users.findOne @vOf()
    
    Template.user_info_small.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info_small.helpers
        user: -> Meteor.users.findOne @vOf()
    
    Template.user_info_tiny.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info_tiny.helpers
        user: -> Meteor.users.findOne @vOf()

#
    Template.user_avatar.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_avatar.helpers
        user: -> Meteor.users.findOne @vOf()

#
#     Template.toggle_edit.events
#         'click .toggle_edit': ->
#             console.log @
#             console.log Template.currentData()
#             console.log Template.parentData()
#             console.log Template.parentData(1)
#             console.log Template.parentData(2)
#             console.log Template.parentData(3)
#             console.log Template.parentData(4)
#
#
#
#
#
#     Template.user_list_info.onCreated ->
#         @autorun => Meteor.subscribe 'user', @data
#
#     Template.user_list_info.helpers
#         user: ->
#             console.log @
#             Meteor.users.findOne @vOf()
#
#
#
    Template.bookmark_button.events
        'click .toggle': (e,t)->
            console.log @
            $(e.currentTarget).closest('.button').transition('pulse',200)
            if Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids
                Meteor.users.update Meteor.userId(),
                    $pull:"bookmark_ids": @_id
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet:"bookmark_ids": @_id

    Template.bookmark_button.helpers
        bookmark_button_class: ->
            if Meteor.user()
                if Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids then 'active' else 'basic'
            else
                'disabled'

        bookmarked: ->
            if Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids then true else false
#
#
#
#
    Template.user_list_toggle.onCreated ->
        @autorun => Meteor.subscribe 'user_list', Template.parentData(),@k
    Template.user_list_toggle.events
        'click .toggle': (e,t)->
            p = Template.parentData()
            $(e.currentTarget).closest('.button').transition('pulse',200)
            if p["#{@k}"] and Meteor.userId() in p["#{@k}"]
                Docs.update parent._id,
                    $pull:"#{@k}":Meteor.userId()
            else
                Docs.update parent._id,
                    $addToSet:"#{@k}":Meteor.userId()
    Template.user_list_toggle.helpers
        user_list_toggle_class: ->
            if Meteor.user()
                p = Template.parentData()
                if p["#{@k}"] and Meteor.userId() in p["#{@k}"] then 'active' else 'basic'
            else
                'disabled'
        in_list: ->
            p = Template.parentData()
            if p["#{@k}"] and Meteor.userId() in p["#{@k}"] then true else false
        list_users: ->
            p = Template.parentData()
            Meteor.users.find(_id:$in:p["#{@k}"]).fetch()

#
#
#
    Template.viewing.events
        'click .mark_read': (e,t)->
            Docs.update @_id,
                $inc:views:1
            unless @read_ids and Meteor.userId() in @read_ids
                Meteor.call 'mark_read', @_id, ->
                    # $(e.currentTarget).closest('.comment').transition('pulse')
                    $('.unread_icon').transition('pulse')
        'click .mark_unread': (e,t)->
            Docs.update @_id,
                $inc:views:-1
            Meteor.call 'mark_unread', @_id, ->
                # $(e.currentTarget).closest('.comment').transition('pulse')
                $('.unread_icon').transition('pulse')
    Template.viewing.helpers
        viewed_by: -> Meteor.userId() in @read_ids
        readers: ->
            readers = []
            if @read_ids
                for reader_id in @read_ids
                    unless reader_id is @_author_id
                        readers.push Meteor.users.findOne reader_id
            readers
#
#
#
#
if Meteor.isClient
    Template.email_validation_check.events
        'click .send_verification': ->
            console.log @
            if confirm 'send verification email?'
                Meteor.call 'verify_email', @_id, ->
                    alert 'verification email sent'
        'click .toggle_email_verified': ->
            console.log @emails[0].verified
            if @emails[0]
                Meteor.users.update @_id,
                    $set:"emails.0.verified":true
#
#
#     Template.add_button.onCreated ->
#         # console.log @
#         Meteor.subscribe 'model_from_slug', @data.model
#     Template.add_button.helpers
#         model: ->
#             data = Template.currentData()
#             Docs.findOne
#                 model: 'model'
#                 slug: data.model
#     Template.add_button.events
#         'click .add': ->
#             new_id = Docs.insert
#                 model: @model
#             Router.go "/m/#{@model}/#{new_id}/edit"
#
#
    Template.remove_button.events
        'click .remove_doc': (e,t)->
            $('body').toast
              message: "confirm delete #{@title}?"
              displayTime: 0
              class: 'black'
              actions: [
                {
                  text: 'yes'
                  icon: 'remove'
                  class: 'red'
                  click: ->
                    Docs.remove @_id
                    $('body').toast message: 'deleted'
                }
                {
                  icon: 'ban'
                  text: 'cancel'
                  class: 'icon yellow'
                }
                # {
                #   text: '?'
                #   class: 'blue'
                #   click: ->
                #     $('body').toast message: 'Returning false from the click handler avoids closing the toast '
                #     false
            
                # }
              ]
            # if confirm "remove #{@model}?"
            #     # if $(e.currentTarget).closest('.card')
            #     #     $(e.currentTarget).closest('.card').transition('fly right', 1000)
            #     # else
            #     #     $(e.currentTarget).closest('.segment').transition('fly right', 1000)
            #     #     $(e.currentTarget).closest('.item').transition('fly right', 1000)
            #     #     $(e.currentTarget).closest('.content').transition('fly right', 1000)
            #     #     $(e.currentTarget).closest('tr').transition('fly right', 1000)
            #     #     $(e.currentTarget).closest('.event').transition('fly right', 1000)
            #     # Meteor.setTimeout =>
            #     # , 1000


    Template.remove_icon.events
        'click .remove_doc': (e,t)->
            console.log 'hi'
            $('body').toast
                message: "confirm delete #{@title}?"
                displayTime: 0
                class: 'black'
                actions: [
                    {
                        text: 'yes'
                        icon: 'remove'
                        class: 'red'
                        click: ->
                            Docs.remove @_id
                            $('body').toast message: 'deleted'
                    }
                    {
                        icon: 'ban'
                        text: 'cancel'
                        class: 'icon yellow'
                    }
                ]
            
            # if confirm "remove #{@model}?"
            #     if $(e.currentTarget).closest('.card')
            #         $(e.currentTarget).closest('.card').transition('fly right', 1000)
            #     else
            #         $(e.currentTarget).closest('.segment').transition('fly right', 1000)
            #         $(e.currentTarget).closest('.item').transition('fly right', 1000)
            #         $(e.currentTarget).closest('.content').transition('fly right', 1000)
            #         $(e.currentTarget).closest('tr').transition('fly right', 1000)
            #         $(e.currentTarget).closest('.event').transition('fly right', 1000)
            #     Meteor.setTimeout =>
            #         Docs.remove @_id
            #     , 1000

#
#     Template.view_user_button.events
#         'click .view_user': ->
#             Router.go "/u/#{username}"
#
#
#     Template.user_array_element_toggle.helpers
#         user_array_element_toggle_class: ->
#             # user = Meteor.users.findOne Router.current().params.username
#             if @user["#{@k}"] and @v in @user["#{@k}"] then 'active' else 'basic'
#     Template.user_array_element_toggle.events
#         'click .toggle_element': (e,t)->
#             # user = Meteor.users.findOne Router.current().params.username
#             if @user["#{@k}"]
#                 if @v in @user["#{@k}"]
#                     Meteor.users.update @user._id,
#                         $pull: "#{@k}":@v
#                 else
#                     Meteor.users.update @user._id,
#                         $addToSet: "#{@k}":@v
#             else
#                 Meteor.users.update @user._id,
#                     $addToSet: "#{@k}":@v
#
#
#     Template.user_array_list.helpers
#         users: ->
#             users = []
#             if @user["#{@array}"]
#                 for user_id in @user["#{@array}"]
#                     user = Meteor.users.findOne user_id
#                     users.push user
#                 users
#
#
#
#     Template.user_array_list.onCreated ->
#         @autorun => Meteor.subscribe 'user_array_list', @data.user, @data.array
#     Template.user_array_list.helpers
#         users: ->
#             users = []
#             if @user["#{@array}"]
#                 for user_id in @user["#{@array}"]
#                     user = Meteor.users.findOne user_id
#                     users.push user
#                 users
#
#
#
#
    Template.kve.events
        'click .set_key_v': ->
            p = Template.parentData()
            # console.log 'hi'
            # parent = Docs.findOne @_id
            Docs.update p._id,
                $set: "#{@k}": @v

    Template.kve.helpers
        set_kv_class: ->
            # parent = Docs.findOne @_id
            p = Template.parentData()
            # console.log parent
            if p["#{@k}"] is @v then 'active' else 'basic'
    
    Template.user_kve.events
        'click .set_key_v': ->
            p = Template.parentData()
            # console.log 'hi'
            # parent = Docs.findOne @_id
            Meteor.users.update parent._id,
                $set: "#{@k}": @value

    Template.user_kve.helpers
        set_kv_class: ->
            # parent = Docs.findOne @_id
            p = Template.parentData()
            # console.log parent
            if p["#{@k}"] is @value then 'active' else 'basic'

    Template.skve.events
        'click .set_session_v': ->
            # console.log @k
            # console.log @v
            if Session.equals(@k,@v)
                Session.set(@k, null)
            else
                Session.set(@k, @v)

    Template.skve.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @classes
                res += @classes
            if Session.get(@k)
                if Session.equals(@k,@v)
                    res += ' blue large compact circular'
                else
                    # res += ' compact displaynone'
                    res += ' compact basic circular'
                # console.log res
                res
            else
                'basic circular'
        selected: -> Session.equals(@k,@v)



    Template.sbt.events
        'click .toggle_session_key': ->
            console.log @k
            Session.set(@k, !Session.get(@k))

    Template.sbt.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @classes
                res += @classes
            if Session.get(@k)
                res += ' black'
            else
                res += ' basic'

            # console.log res
            res

#
#
#     Template.doc_array_togggle.helpers
#         doc_array_toggle_class: ->
#             p = Template.parentData()
#             # user = Meteor.users.findOne Router.current().params.username
#             if p["#{@k}"] and @v in p["#{@k}"] then 'active' else 'basic'
#     Template.doc_array_togggle.events
#         'click .toggle': (e,t)->
#             p = Template.parentData()
#             if p["#{@k}"]
#                 if @v in p["#{@k}"]
#                     Docs.update parent._id,
#                         $pull: "#{@k}":@v
#                 else
#                     Docs.update parent._id,
#                         $addToSet: "#{@k}":@v
#             else
#                 Docs.update parent._id,
#                     $addToSet: "#{@k}":@v
#
#
#
#
#
#
#
#
#
# if Meteor.isServer
#     Meteor.methods
#         'send_kiosk_message': (message)->
#             parent = Docs.findOne message.parent._id
#             Docs.update message._id,
#                 $set:
#                     sent: true
#                     sent_timestamp: Date.now()
#             Docs.insert
#                 model:'log_event'
#                 log_type:'kiosk_message_sent'
#                 text:"kiosk message sent"
#
#
#     Meteor.publish 'rules_signed_username', (username)->
#         Docs.find
#             model:'rules_and_regs_signing'
#             student:username
#             # agree:true
#
#     Meteor.publish 'type', (type)->
#         Docs.find
#             type:type
#
#     Meteor.publish 'user_guidelines_username', (username)->
#         Docs.find
#             model:'user_guidelines_signing'
#             # student:username
#             # agree:true
#
#     Meteor.publish 'guests', ()->
#         Meteor.users.find
#             roles:$in:['guest']
#
#
#     Meteor.publish 'children', (model, parent_id, limit)->
#         # console.log model
#         # console.log parent_id
#         limit = if limit then limit else 10
#         Docs.find {
#             model:model
#             parent_id:parent_id
#         }, limit:limit