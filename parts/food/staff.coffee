if Meteor.isClient
    Router.route "/staff", (->
        @layout 'layout'
        @render 'staff'
        ), name:'staff'
    
    Template.staff_tasks.onCreated ->
        @autorun => Meteor.subscribe 'staff_tasks'
    Template.staff_tasks.helpers
        tasks: ->
            Docs.find
                model:'task'



    Template.working_staff.onCreated ->
        @autorun => Meteor.subscribe 'checked_in_staff'
    Template.working_staff.helpers
        checked_in_staff: ->
            Meteor.users.find
                roles:$in:['staff']
                checked_in:true



    Template.staff_beer.onCreated ->
        @autorun => Meteor.subscribe 'tapped_kegs'
    Template.staff_beer.helpers
        tapped_kegs: ->
            Docs.find
                model:'drink'
                # tapped:true

        new_kegs: ->
            Docs.find
                model:'drink'
                # new:true


    Template.staff_events.onCreated ->
        @autorun => Meteor.subscribe 'todays_events'
    Template.staff_events.helpers
        todays_events: ->
            Docs.find
                model:'event'


    Template.staff_food_trucks.onCreated ->
        @autorun => Meteor.subscribe 'staff_food_trucks'
    Template.staff_food_trucks.helpers
        food_tucks: ->
            Docs.find
                model:'food_truck'



if Meteor.isServer
    Meteor.publish 'staff_tasks', ->
        Docs.find
            model:'task'
    Meteor.publish 'checked_in_staff', ->
        Meteor.users.find
            roles:$in:['staff']
            checked_in:true
    Meteor.publish 'tapped_kegs', ->
        Docs.find
            model:'drink'
            tapped:true
    Meteor.publish 'new_kegs', ->
        Docs.find
            model:'drink'
            new:true
    Meteor.publish 'todays_events', ->
        Docs.find
            model:'event'

    Meteor.publish 'staff_food_trucks', ->
        Docs.find
            model:'food_truck'
