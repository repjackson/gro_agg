request = require('request')
rp = require('request-promise');

Meteor.publish 'ea_docs', ->
    Docs.find {
        model:'ea'
    }, limit:20
Meteor.methods 
    call_ea: (input)->
        # HTTP.get "https://environment.data.gov.uk/public-register/search.json?"
        url = "https://environment.data.gov.uk/public-register/waste-carriers-brokers/registration.json?_limit=20"
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    console.log item
                    found = 
                        Docs.findOne
                            model:'ea'
                            edata:item
                    if found
                        console.log found
                        # Docs.update found._id,
                        #     $set:body:item.body
                    unless found
                        doc = {}
                        doc.model = 'ea'
                        doc.edata = item
                        new_id = 
                            Docs.insert doc
            )).catch((err)->
            )
