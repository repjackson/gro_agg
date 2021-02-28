Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'

Template.home.onCreated ->
    params = new URLSearchParams(window.location.search);
    
    tags = params.get("tags");
    if tags
        split = tags.split(',')
        if tags.length > 0
            for tag in split 
                picked_tags.push tag
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 5000    
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 10000    
            
    # console.log(name)
    
    Session.setDefault('sort_key', 'points')
    Session.setDefault('sort_direction', -1)
    Session.setDefault('view_layout', 'grid')
    # Session.setDefault('view_sidebar', -false)
    Session.setDefault('view_videos', -false)
    Session.setDefault('view_images', -false)
    Session.setDefault('view_adult', -false)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'dao_tags',
        picked_tags.array()
        Session.get('toggle')
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
        Session.get('view_videos')
        Session.get('view_images')
        Session.get('view_adult')
    @autorun => Meteor.subscribe 'post_count', 
        picked_tags.array()
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
        Session.get('view_videos')
        Session.get('view_images')
        Session.get('view_adult')
    @autorun => Meteor.subscribe 'posts', 
        picked_tags.array()
        Session.get('toggle')
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('skip_value')
        Session.get('view_videos')
        Session.get('view_images')
        Session.get('view_adult')



Template.home.helpers
    posts: ->
        Docs.find {
            model:'rpost'
        }, sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
       
    picked_tags: -> picked_tags.array()
    # picked_locations: -> picked_locations.array()
    # picked_authors: -> picked_authors.array()
    # picked_times: -> picked_times.array()
    post_counter: -> Counts.get 'post_counter'
    
    nightmode_class: -> if Session.get('nightmode') then 'invert'
    
    
    result_tags: -> results.find(model:'tag')
    # author_results: -> results.find(model:'author')
    # location_results: -> results.find(model:'location_tag')
    # time_results: -> results.find(model:'time_tag')
    
    sort_points_class: -> if Session.equals('sort_key','points') then 'black' else 'basic'
    sort_timestamp_class: -> if Session.equals('sort_key','_timestamp') then 'black' else 'basic'
    video_class: -> if Session.get('view_videos') then 'black' else 'basic'
    image_class: -> if Session.get('view_images') then 'black' else 'basic'
    adult_class: -> if Session.get('view_adult') then 'black' else 'basic'
    
    # sidebar_class: -> if Session.get('view_sidebar') then 'ui four wide column' else 'hidden'
    # main_column_class: -> if Session.get('view_sidebar') then 'ui twelve wide column' else 'ui sixteen wide column' 
        
Template.home.events
    # 'click .enable_sidebar': (e,t)-> Session.set('view_sidebar',true)
    # 'click .disable_sidebar': (e,t)-> Session.set('view_sidebar',false)
    # 'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
    'click .sort_up': (e,t)-> Session.set('sort_direction',1)
    'click .toggle_nightmode': -> Session.set('nightmode',!Session.get('nightmode'))
  
    'click .view_videos': (e,t)-> Session.set('view_videos',!Session.get('view_videos'))
    'click .view_images': (e,t)-> Session.set('view_images',!Session.get('view_images'))
    'click .view_adult': (e,t)-> 
        unless Session.get('view_adult')
            if confirm 'view adult?'
                Session.set('view_adult',true)
        else
            Session.set('view_adult',false)
            # Session.set('view_adult',!Session.get('view_adult'))

    'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
    'click .set_list': (e,t)-> Session.set('view_layout', 'list')

    'click .sort_points': (e,t)-> Session.set('sort_key', 'points')
    'click .sort_timestamp': (e,t)-> Session.set('sort_key', '_timestamp')

    # 'click .mark_viewed': (e,t)->
    #     Docs.update @_id,
    #         $inc:views:1
    'click .search_tag': (e,t)->
        Session.set('toggle', !Session.get('toggle'))

    'keyup .search_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_tag').val().trim().toLowerCase()
            Session.set('loading',true)
            picked_tags.push val   
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val
            $('.search_tag').transition('pulse')
            $('.black').transition('pulse')
            $('.seg .pick_tag').transition({
                animation : 'pulse',
                duration  : 500,
                interval  : 300
            })
            $('.seg .black').transition({
                animation : 'pulse',
                duration  : 500,
                interval  : 300
            })
            $('.pick_tag').transition('pulse')
            $('.card_small').transition('shake')
            $('.pushed .card').transition({
                animation : 'pulse',
                duration  : 500,
                interval  : 300
            })
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 5000    
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 10000    
            url = new URL(window.location);
            url.searchParams.set('tags', picked_tags.array());
            window.history.pushState({}, '', url);
            document.title = picked_tags.array()
            
            t.$('.search_tag').val('')
            t.$('.search_tag').focus()
            # Session.set('sub_doc_query', val)



    'click .make_private': ->
        # if confirm 'make private?'
        Docs.update @_id,
            $set:is_private:true

    # 'keyup .add_tag': (e,t)->
    #     if e.which is 13
    #         new_tag = $(e.currentTarget).closest('.add_tag').val().toLowerCase().trim()
    #         Docs.update @_id,
    #             $addToSet: tags:new_tag
    #         $(e.currentTarget).closest('.add_tag').val('')
            
