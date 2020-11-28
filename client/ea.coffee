Router.route '/ea', (->
    @layout 'layout'
    @render 'ea'
    ), name:'ea'


Template.ea.onCreated ->
    @autorun -> Meteor.subscribe 'ea_docs'

Template.ea.onRendered ->

Template.ea.helpers
    ea_docs: ->
        Docs.find({
            model:'ea'
        }, {
            sort:score:-1
        })
    answer_class: -> if @accepted then 'accepted'


Template.ea.events
    'click .goto_q': -> Router.go "/s/#{Router.current().params.site}/q/#{@question_id}"


    'click .get_ea': (e,t)->
        Meteor.call 'call_ea', ->

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
