request = require('request')
rp = require('request-promise');

Meteor.publish 'ea_docs', (
    selected_reg_type
    name_query=''
    location_query=''
    type_query=''
    number_query=''
    )->
    match = {model:'ea'}
    # if selected_reg_type.length > 0
    #     match['registrationType.label'] = $in: selected_reg_type
    #     # match['holder.title'] = {$regex:"#{selected_reg_type}"}
    if name_query and name_query.length > 0
        match["edata.holder.name"] = {$regex:"#{name_query}",$options:'i'}
    if location_query and location_query.length > 0
        match['edata.site.siteAddress.address'] = {$regex:"#{location_query}",$options:'i'}
    if type_query and type_query.length > 0
        match['edata.regime.prefLabel'] = {$regex:"#{type_query}",$options:'i'}
    if number_query and number_query.length > 0
        match['edata.registrationNumber'] = {$regex:"#{number_query}",$options:'i'}
    console.log match
    Docs.find match
    , limit:20
    
    
    
# Meteor.methods 
    # call_ea: (input)->
    #     # HTTP.get "https://environment.data.gov.uk/public-register/search.json?"
    #     url = "https://environment.data.gov.uk/public-register/waste-carriers-brokers/registration.json?_limit=20"
    #     options = {
    #         url: url
    #         headers: 'accept-encoding': 'gzip'
    #         gzip: true
    #     }
    #     rp(options)
    #         .then(Meteor.bindEnvironment((data)->
    #             parsed = JSON.parse(data)
    #             for item in parsed.items
    #                 console.log item
    #                 found = 
    #                     Docs.findOne
    #                         model:'ea'
    #                         edata:item
    #                 if found
    #                     console.log found
    #                     # Docs.update found._id,
    #                     #     $set:body:item.body
    #                 unless found
    #                     doc = {}
    #                     doc.model = 'ea'
    #                     doc.edata = item
    #                     new_id = 
    #                         Docs.insert doc
    #         )).catch((err)->
    #         )
