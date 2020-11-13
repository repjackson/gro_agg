Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'stack'
    loadingTemplate: 'splash'
    trackPageView: false
# 	progressTick: false
# 	progressDelay: 100
# Router.route '*', -> @render 'not_found'

# # Router.route '/u/:username/m/:type', -> @render 'profile', 'user_section'

# Router.route '/forgot_password', -> @render 'forgot_password'


Router.route '/', (->
    @layout 'layout'
    @render 'dao'
    ), name:'home'

# Router.route '/question/:doc_id/view', (->
#     @render 'question_view'
#     ), name:'question_view'
# Router.route '/question/:doc_id/edit', (->
#     @render 'question_edit'
#     ), name:'question_edit'
