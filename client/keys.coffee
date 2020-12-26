globalHotkeys = new Hotkeys();
globalHotkeys.add
	combo: "d r"
	callback: ->
        model_slug =  Router.current().params.model_slug
        Session.set 'loading', true
        Meteor.call 'set_facets', model_slug, ->
            Session.set 'loading', false

globalHotkeys.add
	combo: "m c"
	callback: ->
        model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        Router.go "/model/edit/#{model._id}"

globalHotkeys.add
	combo: "d s"
	callback: ->
        doc = Docs.findOne Router.current().params.doc_id
        Router.go "/m/#{doc.model}/#{doc._id}/view"
        # model = Docs.findOne Router.current().params.doc_id
        # Router.go "/m/#{model.slug}"

globalHotkeys.add
	combo: "d e"
	callback: ->
        doc = Docs.findOne Router.current().params.doc_id
        Router.go "/m/#{doc.model}/#{doc._id}/edit"


globalHotkeys.add
	combo: "r a"
	callback: ->
		if Meteor.user()
			if Meteor.userId() in ['vwCi2GTJgvBJN5F6c']
				if Meteor.user().roles
		            if 'admin' in Meteor.user().roles
		                Meteor.users.update Meteor.userId(), $pull:roles:'admin'
		            else
		                Meteor.users.update Meteor.userId(), $addToSet:roles:'admin'
				else
					Meteor.users.update Meteor.userId(),
						$set: roles:['admin']
globalHotkeys.add
	combo: "r d"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c']
            if Meteor.user().roles and 'dev' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'dev'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'dev'

globalHotkeys.add
	combo: "?"
	callback: ->
		# Swal.fire({
		# 	position: 'top-end',
		# 	icon: 'success',
		# 	title: 'Your work has been saved',
		# 	showConfirmButton: false,
		# 	timer: 1500
		# })
		$('.ui.modal').modal('show')
		# Swal.fire
		# 	title: 'keyboard shortcuts',
		# 	icon: 'info',
		# 	# html: "<ul> <li><b>g h</b>: go home</li> <li><b>g i</b>: ingredients</li> <li><b>g p</b>: profile</li> <li><b>r a</b>: toggle admin role</li> </ul>"
	    #     showCancelButton: false,
	    #     confirmButtonText: 'close'



# globalHotkeys.add
# 	combo: "r o"
# 	callback: ->
#         if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c']
#             if 'tutor' in Meteor.user().roles
#                 Meteor.users.update Meteor.userId(), $pull:roles:'tutor'
#             else
#                 Meteor.users.update Meteor.userId(), $addToSet:roles:'tutor'


globalHotkeys.add
	combo: "g h"
	callback: -> Router.go '/m/model'
globalHotkeys.add
	combo: "g i"
	callback: -> Router.go '/m/ingredient'
globalHotkeys.add
	combo: "g f"
	callback: -> Router.go '/m/field_type'
globalHotkeys.add
	combo: "g t"
	callback: -> Router.go '/m/tribe'
globalHotkeys.add
	combo: "g d"
	callback: -> Router.go '/m/dish'

globalHotkeys.add
	combo: "s d"
	callback: ->
        current_model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        Router.go "/m/#{current_model.slug}/#{Router.current().params.doc_id}/view"
globalHotkeys.add
	combo: "g u"
	callback: ->
        model_slug =  Router.current().params.model_slug
        Session.set 'loading', true
        Meteor.call 'set_facets', model_slug, ->
            Session.set 'loading', false
        Router.go "/m/#{model_slug}/"
globalHotkeys.add
	combo: "g p"
	callback: -> Router.go "/user/#{Meteor.user().username}"
# globalHotkeys.add
# 	combo: "g i"
# 	callback: -> Router.go "/inbox"
globalHotkeys.add
	combo: "g a"
	callback: -> Router.go "/admin"
# globalHotkeys.add
# 	combo: "g a"
# 	callback: -> Router.go "/admin"


globalHotkeys.add
	combo: "a d"
	callback: ->
        model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        # console.log model
        if model.collection and model.collection is 'users'
            name = prompt 'first and last name'
            split = name.split ' '
            first_name = split[0]
            last_name = split[1]
            username = name.split(' ').join('_')
            # console.log username
            Meteor.call 'add_user', first_name, last_name, username, 'guest', (err,res)=>
                if err
                    alert err
                else
                    Meteor.users.update res,
                        $set:
                            first_name:first_name
                            last_name:last_name
                    Router.go "/m/#{model.slug}/#{res}/edit"
        else
            new_doc_id = Docs.insert
                model:model.slug
            Router.go "/m/#{model.slug}/#{new_doc_id}/edit"
