if Meteor.isClient
    Template.print_this.events
        'click .print_this': ->
            console.log @
    Template.comments.onCreated ->
        @autorun => Meteor.subscribe 'children', 'comment', Router.current().params.doc_id
    Template.comments.helpers
        doc_comments: ->
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.parentData()._id
            Docs.find
                model:'comment'
                parent_id:parent._id
                    
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                if Router.current().params.doc_id
                    parent = Docs.findOne Router.current().params.doc_id
                else
                    parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne Router.current().params.doc_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    parent_model:parent.model
                    body:comment
                t.$('.add_comment').val('')

        'click .remove_comment': ->
            if confirm 'confirm remove comment'
                Docs.remove @_id

    Template.voting.events
        'click .upvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->
    Template.voting_small.events
        'click .upvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->
#
#    Template.skve.events
        'click .set_session_v': ->
            # if Session.equals(@k,@v)
            #     Session.set(@k, null)
            # else
            Session.set(@k, @v)

    Template.skve.helpers
        calculated_class: ->
            res = ''
            if @classes
                res += @classes
            if Session.get(@k)
                if Session.equals(@k,@v)
                    res += ' large compact black'
                else
                    # res += ' compact displaynone'
                    res += ' compact basic '
                res
            else
                'basic '
        selected: -> Session.equals(@k,@v)





#
    Template.call_watson.events
        'click .autotag': ->
            doc = Docs.findOne Router.current().params.doc_id
            console.log doc
            console.log @
    
            Meteor.call 'call_watson', doc._id, @key, @mode
#
    Template.voting_full.events
        'click .upvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->

    Template.remove_button.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                Docs.remove @_id
                # , 1000


    Template.remove_icon.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000