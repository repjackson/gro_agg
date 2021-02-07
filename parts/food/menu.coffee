if Meteor.isClient
    Router.route '/menu', -> @render 'menu'
    
    Template.menu.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'drink_category'
        @autorun -> Meteor.subscribe 'model_docs', 'drink'

    Template.menu.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000


    Template.menu.helpers
        drink_categories: ->
            Docs.find {
                model:'drink_category'
            }

    Template.drink_category_segment.helpers
        category_drinks: ->
            console.log @
            Docs.find {
                model:'drink'
                category_ids:$in:[@_id]
            }
