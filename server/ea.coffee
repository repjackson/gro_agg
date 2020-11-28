Meteor.methods 
    call_ea: (input)->
        # HTTP.get "https://environment.data.gov.uk/public-register/search.json?"
        HTTP.get "https://environment.data.gov.uk/public-register/waste-carriers-brokers/registration.json?_limit=20", (err,res)->
            if res
                console.log res
                