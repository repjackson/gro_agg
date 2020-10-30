Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false
# 	progressTick: false
# 	progressDelay: 100


force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

Router.onBeforeAction(force_loggedin, {
    # only: ['admin']
    except: [
        'home'
        # 'profile'
        # 'shop'
        'chat'
        'web'
        'dao'
        'model_doc_view'
        'reddit_view'
        'doc_view'
        'post_view'
        # 'post_edit'
        'register'
        'login'
        'verify-email'
        'forgot_password'
    ]
    })


Router.route('enroll', {
    path: '/enroll-account/:token'
    template: 'reset_password'
    onBeforeAction: ()=>
        Meteor.logout()
        Session.set('_resetPasswordToken', this.params.token)
        @subscribe('enrolledUser', this.params.token).wait()
})


Router.route('verify-email', {
    path:'/verify-email/:token',
    onBeforeAction: ->
        console.log @
        # Session.set('_resetPasswordToken', this.params.token)
        # @subscribe('enrolledUser', this.params.token).wait()
        console.log @params
        Accounts.verifyEmail(@params.token, (err) =>
            if err
                console.log err
                alert err
                @next()
            else
                # alert 'email verified'
                # @next()
                Router.go "/verification_confirmation/"
        )
})


Router.route '/verification_confirmation', -> @render 'verification_confirmation'
Router.route '*', -> @render 'not_found'

# Router.route '/u/:username/m/:type', -> @render 'profile', 'user_section'

Router.route '/forgot_password', -> @render 'forgot_password'


Router.route '/', (->
    @layout 'layout'
    @render 'dao'
    ), name:'home'



Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'

Router.route '/question/:doc_id/view', (->
    @render 'question_view'
    ), name:'question_view'
Router.route '/question/:doc_id/edit', (->
    @render 'question_edit'
    ), name:'question_edit'