Router.route '/ea', (->
    @layout 'layout'
    @render 'ea'
    ), name:'ea'


Template.ea.onCreated ->

Template.ea.onRendered ->


Template.ea.helpers
    question_comments: ->
        Docs.find({
            model:'stack_comment'
            post_id:parseInt(Router.current().params.qid)
            site:Router.current().params.site
        }, {
            sort:score:-1
        })
    answer_class: -> if @accepted then 'accepted'


Template.ea.events
    'click .goto_q': -> Router.go "/s/#{Router.current().params.site}/q/#{@question_id}"


    'click .get_ea': (e,t)->
        Meteor.call 'call_ea', ->

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
