# if Meteor.isClient
    # Router.route '/', (->
    #     @layout 'layout'
    #     @render 'home'
    #     ), name:'home'

Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false
