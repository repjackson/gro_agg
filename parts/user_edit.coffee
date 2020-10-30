if Meteor.isClient
    Router.route '/u/:username/edit/', (->
        @layout 'user_edit_layout'
        @render 'user_edit_account'
        ), name:'user_edit_home'
    Router.route '/u/:username/edit/info', (->
        @layout 'user_edit_layout'
        @render 'user_edit_info'
        ), name:'user_edit_info'
    Router.route '/u/:username/edit/badges', (->
        @layout 'user_edit_layout'
        @render 'user_edit_badges'
        ), name:'user_edit_badges'
    Router.route '/u/:username/edit/payment', (->
        @layout 'user_edit_layout'
        @render 'user_edit_payment'
        ), name:'user_edit_payment'
    Router.route '/u/:username/edit/account', (->
        @layout 'user_edit_layout'
        @render 'user_edit_account'
        ), name:'user_edit_account'

    Template.user_edit_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_from_id', Router.current().params.user_id

    Template.user_edit_layout.onRendered ->
        # Meteor.setTimeout ->
        #     $('.button').popup()
        # , 2000

    Template.registerHelper 'current_user', () -> Meteor.users.findOne username:Router.current().params.username

    # Template.phone_editor.helpers
    #     'newNumber': ->
    #         Phoneformat.formatLocal 'US', Meteor.user().profile.phone

    Template.user_edit_layout.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/users"

        "change input[name='profile_image']": (e) ->
            files = e.currentTarget.files
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.dir res
                    if err
                        console.error 'Error uploading', err
                    else
                        user = Meteor.users.findOne username:Router.current().params.username
                        Meteor.users.update user._id,
                            $set: "image_id": res.public_id
                    return


    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            if new_username
                if confirm "change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/u/#{new_username}")




    Template.password_edit.events
        'click .change_password': (e, t) ->
            Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
                if err
                    alert err.reason
                else
                    alert 'password changed'
                    # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'set_password', current_user._id, new_password, ->
                alert "password set to #{new_password}."

        'click .send_password_reset_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'send_password_reset_email', current_user._id, @address, ->
                alert 'password reset email sent'


        'click .send_enrollment_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'send_enrollment_email', current_user._id, @address, ->
                alert 'enrollment email sent'


    Template.emails_edit.helpers

    Template.emails_edit.events
        'click #add_email': ->
            new_email = $('#new_email').val().trim()
            current_user = Meteor.users.findOne username:Router.current().params.username

            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            valid_email = re.test(new_email)

            if valid_email
                Meteor.call 'add_email', current_user._id, new_email, (error, result) ->
                    if error
                        alert "error adding email: #{error.reason}"
                    else
                        # alert result
                        $('#new_email').val('')
                    return

        'click .remove_email': ->
            if confirm 'remove email?'
                current_user = Meteor.users.findOne username:Router.current().params.username
                Meteor.call 'remove_email', current_user._id, @address, (error,result)->
                    if error
                        alert "error removing email: #{error.reason}"


        'click .send_verification_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'verify_email', current_user._id, @address, ->
                alert 'verification email sent'
    
    Template.registerHelper 'current_user', () -> Meteor.users.findOne username:Router.current().params.username

    # Template.phone_editor.helpers
    #     'newNumber': ->
    #         Phoneformat.formatLocal 'US', Meteor.user().profile.phone

    Template.account.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/users"


    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            if new_username
                if confirm "change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/u/#{new_username}")




    Template.password_edit.events
        'click .change_password': (e, t) ->
            Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
                if err
                    alert err.reason
                else
                    alert 'password changed'
                    # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'set_password', current_user._id, new_password, ->
                alert "password set to #{new_password}."

        'click .send_password_reset_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'send_password_reset_email', current_user._id, @address, ->
                alert 'password reset email sent'


        'click .send_enrollment_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'send_enrollment_email', current_user._id, @address, ->
                alert 'enrollment email sent'


    Template.emails_edit.helpers

    Template.emails_edit.events
        'click #add_email': ->
            new_email = $('#new_email').val().trim()
            current_user = Meteor.users.findOne username:Router.current().params.username

            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            valid_email = re.test(new_email)

            if valid_email
                Meteor.call 'add_email', current_user._id, new_email, (error, result) ->
                    if error
                        alert "error adding email: #{error.reason}"
                    else
                        # alert result
                        $('#new_email').val('')
                    return

        'click .remove_email': ->
            if confirm 'remove email?'
                current_user = Meteor.users.findOne username:Router.current().params.username
                Meteor.call 'remove_email', current_user._id, @address, (error,result)->
                    if error
                        alert "error removing email: #{error.reason}"


        'click .send_verification_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'verify_email', current_user._id, @address, ->
                alert 'verification email sent'
                
                
if Meteor.isClient
    Router.route '/u/:username/edit/tribes', (->
        @layout 'user_edit_layout'
        @render 'user_edit_tribes'
        ), name:'user_edit_tribes'

    Template.user_edit_tribes.onRendered ->

    Template.user_edit_tribes.events
        'click .switch': ->
            Swal.fire({
                title: "switch to #{@title}?"
                # text: "this will charge you $5"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm' 
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    Meteor.users.update Meteor.userId(),
                        $set:
                            current_tribe:@_id
                    Swal.fire(
                        'topup initiated',
                        ''
                        'success'
                    )
            )
                
                
if Meteor.isClient
    Router.route '/u/:username/edit/privacy', (->
        @layout 'user_edit_layout'
        @render 'user_edit_privacy'
        ), name:'user_edit_privacy'

    Template.user_edit_privacy.onRendered ->

    Template.user_edit_privacy.events
        'click .logout_other_clients': -> 
            Meteor.logoutOtherClients ->
                $('body').toast({
                    class: 'success',
                    message: "logged out other clients"
                })

    
        'click .force_logout': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update current_user._id,
                $set:'services.resume.loginTokens':[]

    
        'click .add_five_credits': ->
            console.log Template.instance()
            if confirm 'add 5 credits?'
                Session.set('topup_amount',5)
                Template.instance().checkout.open
                    name: 'credit deposit'
                    # email:Meteor.user().emails[0].address
                    description: 'wc top up'
                    amount: 500





            # Swal.fire({
            #     title: 'add 5 credits?'
            #     text: "this will charge you $5"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result)=>
            #     if result.value
            #         Session.set('topup_amount',5)
            #         Template.instance().checkout.open
            #             name: 'credit deposit'
            #             # email:Meteor.user().emails[0].address
            #             description: 'wc top up'
            #             amount: 5
            #
            #         # Meteor.users.update @_author_id,
            #         #     $inc:credit:@order_price
            #         Swal.fire(
            #             'topup initiated',
            #             ''
            #             'success'
            #         )
            # )


if Meteor.isClient
    Router.route '/u/:username/edit/style', (->
        @layout 'user_edit_layout'
        @render 'user_edit_style'
        ), name:'user_edit_style'


    Template.user_edit_style.onCreated ->
        @autorun => Meteor.subscribe 'user_edit_style', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.user_edit_style.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_style.helpers
        user_edit_style: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'picture'
                target_user_id: target_user._id

        transactions: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                _author_id: target_user._id
            }, 
                sort:
                    _timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_edit_style', (username)->
        Docs.find
            model:'picture'

 
if Meteor.isClient
    Router.route '/u/:username/edit/membership', (->
        @layout 'user_edit_layout'
        @render 'user_edit_membership'
        ), name:'user_edit_membership'


    Template.user_edit_membership.onCreated ->
        @autorun => Meteor.subscribe 'user_edit_membership', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.user_edit_membership.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_membership.helpers
        user_edit_membership: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'picture'
                target_user_id: target_user._id

        transactions: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                transaction_type:'membership'
                _author_id: target_user._id
            }, 
                sort:
                    _timestamp:-1
                    
                    
    Template.user_edit_membership.onCreated ->
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) =>
                # amount = parseInt(Session.get('topup_amount'))
                # product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: 25000
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'buy_membership', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'membership purchased',
                            ''
                            'success'
                        Docs.insert
                            model:'transaction'
                            transaction_type:'membership'
                            amount:250
                        Meteor.users.update Meteor.userId(),
                            $inc: points:500
                        )
        )

    Template.user_edit_membership.onRendered ->

    Template.user_edit_membership.events
        'click .pay_membership': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside Membership'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy membership?'
                text: "this will charge you $250"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'Riverside Membership'
                        # email:Meteor.user().emails[0].address
                        description: 'monthly'
                        amount: 250
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )

if Meteor.isServer
    Meteor.publish 'user_edit_membership', (username)->
        Docs.find
            model:'picture'


if Meteor.isClient
    Router.route '/u/:username/edit/genekeys', (->
        @layout 'user_edit_layout'
        @render 'user_edit_genekeys'
        ), name:'user_edit_genekeys'

    Template.user_edit_genekeys.onRendered ->

    Template.user_edit_genekeys.events


if Meteor.isClient
    Router.route '/u/:username/edit/food', (->
        @layout 'user_edit_layout'
        @render 'user_edit_food'
        ), name:'user_edit_food'


    Template.user_edit_food.onCreated ->
        @autorun => Meteor.subscribe 'user_food_orders'
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.user_edit_food.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_food.helpers
        food_orders: ->
            Docs.find
                model:'food_order'

    Template.food_order.events
        'click .submit_order': ->
            if confirm 'submit?'
                Docs.update @_id, 
                    $set:submitted:true

    Template.user_edit_food.onCreated ->
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) =>
                # amount = parseInt(Session.get('topup_amount'))
                # product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: 1100
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'buy_food', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'food purchased',
                            ''
                            'success'
                        # Docs.insert
                        #     model:'transaction'
                        #     transaction_type:'food'
                        #     amount:1100
                        )
        )

    Template.user_edit_food.onRendered ->

    Template.user_edit_food.events
        'click .buy_ethel_tiffen': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside food'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy Ethel food?'
                text: "this will charge you $11"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'buy Ethel Tiffen'
                        # email:Meteor.user().emails[0].address
                        description: 'monthly'
                        amount: 1100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )
            
        'click .buy_nicole_tiffen': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside food'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy food?'
                text: "this will charge you $11"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'Nicole Tiffen'
                        # email:Meteor.user().emails[0].address
                        description: ''
                        amount: 1100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )




if Meteor.isServer
    Meteor.publish 'user_food_orders', (username)->
        Docs.find
            model:'food_order'
            _author_id: Meteor.userId()

if Meteor.isClient
    Router.route '/u/:username/edit/finance', (->
        @layout 'user_edit_layout'
        @render 'user_edit_finance'
        ), name:'user_edit_finance'

    Template.user_edit_finance.onCreated ->
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) ->
                amount = parseInt(Session.get('topup_amount'))
                # product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: amount*100
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'credit_topup', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        Swal.fire(
                            'topup processed',
                            ''
                            'success'
                        Docs.insert
                            model:'transaction'
                            transaction_type:'topup'
                            amount:amount
                        Meteor.users.update Meteor.userId(),
                            $inc: credit:amount
                        )
        )

    Template.user_edit_finance.onRendered ->

    Template.user_edit_finance.events
        'click .add_five_credits': ->
            console.log Template.instance()
            if confirm 'add 5 credits?'
                Session.set('topup_amount',5)
                Template.instance().checkout.open
                    name: 'credit deposit'
                    # email:Meteor.user().emails[0].address
                    description: 'wc top up'
                    amount: 500





            # Swal.fire({
            #     title: 'add 5 credits?'
            #     text: "this will charge you $5"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result)=>
            #     if result.value
            #         Session.set('topup_amount',5)
            #         Template.instance().checkout.open
            #             name: 'credit deposit'
            #             # email:Meteor.user().emails[0].address
            #             description: 'wc top up'
            #             amount: 5
            #
            #         # Meteor.users.update @_author_id,
            #         #     $inc:credit:@order_price
            #         Swal.fire(
            #             'topup initiated',
            #             ''
            #             'success'
            #         )
            # )


if Meteor.isClient
    Router.route '/u/:username/edit/delivery', (->
        @layout 'user_edit_layout'
        @render 'user_edit_delivery'
        ), name:'user_edit_delivery'


    Template.user_edit_delivery.onCreated ->
        @autorun => Meteor.subscribe 'user_delivery_orders'
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.user_edit_delivery.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_delivery.helpers
        delivery_orders: ->
            Docs.find
                model:'delivery_order'


    Template.user_edit_delivery.onCreated ->
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) =>
                # amount = parseInt(Session.get('topup_amount'))
                # product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: 1100
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'buy_delivery', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'delivery purchased',
                            ''
                            'success'
                        # Docs.insert
                        #     model:'transaction'
                        #     transaction_type:'delivery'
                        #     amount:1100
                        )
        )

    Template.user_edit_delivery.onRendered ->

    Template.user_edit_delivery.events
        'click .buy_ethel_tiffen': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside delivery'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy Ethel delivery?'
                text: "this will charge you $11"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'buy Ethel Tiffen'
                        # email:Meteor.user().emails[0].address
                        description: 'monthly'
                        amount: 1100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )
            
        'click .buy_nicole_tiffen': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside delivery'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy delivery?'
                text: "this will charge you $11"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'Nicole Tiffen'
                        # email:Meteor.user().emails[0].address
                        description: ''
                        amount: 1100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )


    Template.delivery.events
        'click submit_order': ->
            console.log 'hi'
            if confirm 'submit?'
                Docs.update @_id, 
                    $set:submitted:true


if Meteor.isServer
    Meteor.publish 'user_delivery_orders', (username)->
        Docs.find
            model:'delivery_order'
            _author_id: Meteor.userId()


if Meteor.isClient
    Router.route '/user/:username/edit/alerts', (->
        @layout 'user_edit_layout'
        @render 'user_edit_alerts'
        ), name:'user_edit_alerts'


    Template.user_edit_alerts.onCreated ->
        @autorun => Meteor.subscribe 'user_edit_alerts', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.user_edit_alerts.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_alerts.helpers
        user_edit_alerts: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'picture'
                target_user_id: target_user._id

        transactions: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                _author_id: target_user._id
            }, 
                sort:
                    _timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_edit_alerts', (username)->
        Docs.find
            model:'picture'
