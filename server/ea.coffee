Meteor.methods 
    call_ea: (input)->
        HTTP.get "https://environment.data.gov.uk/public-register/search.json?"