if Meteor.isClient
    Router.route '/school/', (->
        @layout 'layout'
        @render 'school'
        ), name:'school'
    
    Router.route '/groups/', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'
    

    Template.groups.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'group'
        # @autorun => Meteor.subscribe 'model_docs', 'income'
        
    Template.groups.helpers
        school_total: ->
            group_total = 0
            groups = 
                Docs.find 
                    model:'group'
            for group in groups.fetch()
                group_total += group.amount
            income_total = 0
            incomes = 
                Docs.find 
                    model:'income'
            for income in incomes.fetch()
                income_total += income.amount
            
            income_total - group_total 
            
            
        groups: ->
            Docs.find
                model:'group'
        income: ->
            Docs.find
                model:'income'
        
        group: -> Session.equals('group', @_id)
        editing_income: -> Session.equals('editing_income', @_id)
        
        
    Template.groups.events
        'click .recalc_school_stats': ->
            Meteor.call 'calc_school_stats', ->
                
        'click .group': ->
            Session.set('group',null)
        'click .save_income': ->
            Session.set('editing_income',null)
        'click .group': ->
            Session.set('group',@_id)
        'click .edit_income': ->
            Session.set('editing_income',@_id)
        'click .group': ->
            new_id = 
                Docs.insert 
                    model:'group'
            Session.set('group',new_id)

        'click .add_income': ->
            new_id = 
                Docs.insert 
                    model:'income'
            Session.set('editing_income',new_id)

    # Template.group_stats.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'school_stat'
        
    # Template.group_stats.helpers
    #     fs: ->
    #         Docs.findOne model:'school_stat'
    # Template.group_stats.events
    #     'click .recalc_school_stats': ->
    #         Meteor.call 'calc_school_stats', ->
                



if Meteor.isServer
    # Meteor.publish 'product_from_debit_id', (debit_id)->
    #     debit = Docs.findOne debit_id
    #     Docs.find 
    #         _id:debit.product_id
            
    Meteor.methods
        calc_school_stats: ()->
            fs = Docs.findOne model:'school_stat'
            unless fs 
                Docs.insert 
                    model:'school_stat'
            fs = Docs.findOne model:'school_stat'
            
            group_sum = 0
            
            groups = 
                Docs.find 
                    model:'group'
            for group in groups.fetch()
                group_sum += group.dollar_amount
        
            total_membership_sum = 0
            memberships = 
                Docs.find 
                    model:'group'
                    membership:true
            for membership in memberships.fetch()
                total_membership_sum += membership.dollar_amount
        
            console.log 'total groups', group_sum
            Docs.update fs._id,
                $set:
                    group_sum:group_sum
                    group_count:groups.count()
                    membership_count:memberships.count()
                    total_membership_sum:total_membership_sum