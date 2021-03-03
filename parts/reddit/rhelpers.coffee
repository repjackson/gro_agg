if Meteor.isClient
    Template.registerHelper 'embed', ()->
        if @data and @data.media and @data.media.oembed and @data.media.oembed.html
            dom = document.createElement('textarea')
            # dom.innerHTML = doc.body
            dom.innerHTML = @data.media.oembed.html
            return dom.value
            # Docs.update @_id,
            #     $set:
            #         parsed_selftext_html:dom.value
    
    Template.registerHelper 'is_image', ()->
        if @data.domain in ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','v.redd.it','giphy.com']
            # console.log 'is image'
            true
        else 
            # console.log 'is NOT image'
            false
    Template.registerHelper 'has_thumbnail', ()->
        console.log @data.thumbnail
        @data.thumbnail.length > 0
    
    Template.registerHelper 'is_youtube', ()->
        @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
    
    
