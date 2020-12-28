globalHotkeys = new Hotkeys();


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


