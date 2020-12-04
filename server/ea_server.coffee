# request = require('request')
# rp = require('request-promise');

# Meteor.publish 'e_tags', (
#     picked_localities
#     picked_types
#     picked_postcodes
#     # query=''
#     )->
    
#     self = @
#     match = {model:'ea'}
#     if picked_localities.length > 0 then match["edata.site.siteAddress.locality"] = $all:picked_localities
#     if picked_postcodes.length > 0 then match["edata.site.siteAddress.postcode"] = $all:picked_postcodes
#     if picked_types.length > 0 then match.edata.registrationType.label = $all:picked_types

      
#     localities = Docs.aggregate [
#         { $match: match }
#         { $project: "edata.site.siteAddress.locality": 1 }
#         # { $unwind: "$tags" }
#         { $group: _id: "$edata.site.siteAddress.locality", count: $sum: 1 }
#         # { $match: _id: $nin: selected_tags }
#         { $sort: count: -1, _id: 1 }
#         # { $match: count: $lt: doc_count }
#         { $limit:20 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     localities.forEach (locality, i) ->
#         self.added 'results', Random.id(),
#             name: locality.name
#             count: locality.count
#             model:'locality'

#     postcodes = Docs.aggregate [
#         { $match: match }
#         { $project: "edata.site.siteAddress.postcode": 1 }
#         # { $unwind: "$tags" }
#         { $group: _id: "$edata.site.siteAddress.postcode", count: $sum: 1 }
#         # { $match: _id: $nin: selected_tags }
#         { $sort: count: -1, _id: 1 }
#         # { $match: count: $lt: doc_count }
#         { $limit:20 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     postcodes.forEach (postcode, i) ->
#         self.added 'results', Random.id(),
#             name: postcode.name
#             count: postcode.count
#             model:'postcode'


#     types = Docs.aggregate [
#         { $match: match }
#         { $project: "edata.registrationType.label": 1 }
#         # { $unwind: "$tags" }
#         { $group: _id: "$edata.registrationType.label", count: $sum: 1 }
#         # { $match: _id: $nin: selected_tags }
#         { $sort: count: -1, _id: 1 }
#         # { $match: count: $lt: doc_count }
#         { $limit:20 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     types.forEach (type, i) ->
#         self.added 'results', Random.id(),
#             name: type.name
#             count: type.count
#             model:'type'
#     self.ready()
            
# Meteor.publish 'ea_count', (
#     site
#     )->
        
#     match = {model:'ea'}
#     match.site = site
#     Counts.publish this, 'ea_counter', Docs.find(match)
#     return undefined

# Meteor.publish 'ea_docs', (
#     picked_localities
#     picked_types
#     picked_postcodes
#     name_query=''
#     location_query=''
#     type_query=''
#     number_query=''
#     )->
#     match = {model:'ea'}
#     if picked_localities.length > 0 then match["edata.site.siteAddress.locality"] = $all:picked_localities
#     if picked_types.length > 0 then match["edata.registrationType.label"] = $all:picked_types
#     if picked_postcodes.length > 0 then match["edata.site.siteAddress.postcode"] = $all:picked_postcodes

#     if name_query and name_query.length > 0
#         match["edata.holder.name"] = {$regex:"#{name_query}",$options:'i'}
#     if location_query and location_query.length > 0
#         match['edata.site.siteAddress.address'] = {$regex:"#{location_query}",$options:'i'}
#     if type_query and type_query.length > 0
#         match['edata.regime.prefLabel'] = {$regex:"#{type_query}",$options:'i'}
#     if number_query and number_query.length > 0
#         match['edata.registrationNumber'] = {$regex:"#{number_query}",$options:'i'}
#     console.log match
#     Docs.find match
#     , limit:20
    
    
    
# Meteor.methods 
#     call_ea: (register)->
#         console.log 'register', register
#         # HTTP.get "https://environment.data.gov.uk/public-register/search.json?"
#         url = "https://environment.data.gov.uk/public-register/#{register}/registration.json?_limit=100"
#         options = {
#             url: url
#             headers: 'accept-encoding': 'gzip'
#             gzip: true
#         }
#         rp(options)
#             .then(Meteor.bindEnvironment((data)->
#                 parsed = JSON.parse(data)
#                 for item in parsed.items
#                     console.log item
#                     found = 
#                         Docs.findOne
#                             model:'ea'
#                             edata:item
#                     if found
#                         console.log found.edata.holder.name
#                         # Docs.update found._id,
#                         #     $set:body:item.body
#                     unless found
#                         doc = {}
#                         doc.model = 'ea'
#                         doc.edata = item
#                         new_id = 
#                             Docs.insert doc
#             )).catch((err)->
#             )
