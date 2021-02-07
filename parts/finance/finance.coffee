if Meteor.isClient
    Router.route '/finance/', (->
        @layout 'layout'
        @render 'finance'
        ), name:'finance'
    

    Template.finance.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'expense'
        @autorun => Meteor.subscribe 'model_docs', 'income'
        
    Template.finance.helpers
        finance_total: ->
            expense_total = 0
            expenses = 
                Docs.find 
                    model:'expense'
            for expense in expenses.fetch()
                expense_total += expense.amount
            income_total = 0
            incomes = 
                Docs.find 
                    model:'income'
            for income in incomes.fetch()
                income_total += income.amount
            
            income_total - expense_total 
            
            
        expenses: ->
            Docs.find
                model:'expense'
        income: ->
            Docs.find
                model:'income'
        
        editing_expense: -> Session.equals('editing_expense', @_id)
        editing_income: -> Session.equals('editing_income', @_id)
        
        
    Template.finance.events
        'click .recalc_finance_stats': ->
            Meteor.call 'calc_finance_stats', ->
                
        'click .save_expense': ->
            Session.set('editing_expense',null)
        'click .save_income': ->
            Session.set('editing_income',null)
        'click .edit_expense': ->
            Session.set('editing_expense',@_id)
        'click .edit_income': ->
            Session.set('editing_income',@_id)
        'click .add_expense': ->
            new_id = 
                Docs.insert 
                    model:'expense'
            Session.set('editing_expense',new_id)

        'click .add_income': ->
            new_id = 
                Docs.insert 
                    model:'income'
            Session.set('editing_income',new_id)

    Template.expense_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'finance_stat'
        
    Template.expense_stats.helpers
        fs: ->
            Docs.findOne model:'finance_stat'
    Template.expense_stats.events
        'click .recalc_finance_stats': ->
            Meteor.call 'calc_finance_stats', ->
                



if Meteor.isServer
    # Meteor.publish 'product_from_debit_id', (debit_id)->
    #     debit = Docs.findOne debit_id
    #     Docs.find 
    #         _id:debit.product_id
            
    Meteor.methods
        calc_finance_stats: ()->
            fs = Docs.findOne model:'finance_stat'
            unless fs 
                Docs.insert 
                    model:'finance_stat'
            fs = Docs.findOne model:'finance_stat'
            
            total_expense_sum = 0
            
            expenses = 
                Docs.find 
                    model:'expense'
            for expense in expenses.fetch()
                total_expense_sum += expense.dollar_amount
        
            total_membership_sum = 0
            memberships = 
                Docs.find 
                    model:'expense'
                    membership:true
            for membership in memberships.fetch()
                total_membership_sum += membership.dollar_amount
        
            console.log 'total expenses', total_expense_sum
            Docs.update fs._id,
                $set:
                    total_expense_sum:total_expense_sum
                    total_expense_count:expenses.count()
                    membership_count:memberships.count()
                    total_membership_sum:total_membership_sum