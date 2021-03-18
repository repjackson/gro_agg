if Meteor.isServer
    Meteor.startup () ->
        # Meteor.users.dropIndexes()
        Meteor.users._ensureIndex({ "location": '2dsphere'});
    
    
    Meteor.methods
        tag_coordinates: (doc_id, lat,long)->
            # HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=#{lat}%2C#{long}&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1",(err,response)=>
            HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=#{lat}+#{long}&key=7c21b934bda2463a94bcd5ff74647374&language=en&pretty=1&no_annotations=1",(err,response)=>
                console.log response.data
                if err then console.log err
                else
                    doc = Docs.findOne doc_id
                    user = Meteor.users.findOne doc_id
                    if doc
                        Docs.update doc_id,
                            $set:geocoded:response.data.results
                    if user
                        Meteor.users.update doc_id,
                            $set:geocoded:response.data.results
                    console.log 'working', response
    
            # https://api.opencagedata.com/geocode/v1/json?q=24.77701%2C%20121.02189&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1
            # https://api.opencagedata.com/geocode/v1/json?q=Dhumbarahi%2C%20Kathmandu&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1
    
    
    # Meteor.publish 'nearby_people', (lat,long)->
    Meteor.publish 'nearby_people', (username)->
        user = Meteor.users.findOne username:username
        
        if user
            console.log 'searching for users lat long', user.current_lat, user.current_long
            Meteor.users.find
                light_mode:true
                location:
                    $near:
                        $geometry:
                            type: "Point"
                            coordinates: [user.current_long, user.current_lat]
                            $maxDistance: 2000
