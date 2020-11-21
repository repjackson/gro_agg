globalHotkeys = new Hotkeys();


globalHotkeys.add
	combo: "?"
	callback: ->
		$('.global_search').focus()

		# $('.ui.basic.modal').modal(
		# 	inverted:true
		# 	duration:200
		# 	).modal('show')
		Session.set('current_global_query', null)


globalHotkeys.add
	combo: "u"
	callback: ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance 'users'
        Router.go "/people"
globalHotkeys.add
	combo: "p"
	callback: ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance 'people'
        Router.go "/people"
globalHotkeys.add
	combo: "r"
	callback: ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance 'reddit'
        Router.go "/subreddits"
globalHotkeys.add
	combo: "s"
	callback: ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance 'stack exchange'
        Router.go "/stack"
globalHotkeys.add
	combo: "m"
	callback: ->
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance 'mute'

globalHotkeys.add
	combo: "d"
	callback: ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance 'dao'
        Router.go "/dao"


globalHotkeys.add
	combo: "left"
	callback: ->
        switch Router.current().route.getName()
            when 'stack' 
                Router.go('/dao')
                window.speechSynthesis.speak new SpeechSynthesisUtterance 'goto dao'
            when 'dao' 
                Router.go('/reddit')
                window.speechSynthesis.speak new SpeechSynthesisUtterance 'goto reddit'
            when 'reddit' 
                Router.go('/people')
                window.speechSynthesis.speak new SpeechSynthesisUtterance 'goto people'
globalHotkeys.add
	combo: "right"
	callback: ->
        switch Router.current().route.getName()
            when 'people'
                Router.go('/reddit')
                window.speechSynthesis.speak new SpeechSynthesisUtterance 'goto reddit'
            when 'reddit' 
                Router.go('/dao')
                window.speechSynthesis.speak new SpeechSynthesisUtterance 'goto dao'
            when 'dao' 
                Router.go('/stack')
                window.speechSynthesis.speak new SpeechSynthesisUtterance 'goto stack'
        # Router.go "/reddit"

