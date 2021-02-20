@picked_e = new ReactiveArray []

Router.route '/stats', (->
    @layout 'layout'
    @render 'stats'
    ), name:'stats'


Template.stats.onCreated ->
    @autorun => Meteor.subscribe 'reflection_count'
    @autorun => Meteor.subscribe 'user_count'
    
    
Template.stats.helpers
    user_counter: -> Counts.get 'user_counter'
    reflection_count: -> Counts.get 'reflection_counter'

