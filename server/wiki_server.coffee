Meteor.methods
    search_users: (query)->
        # term = query.split(' ').join('_')
        # term = query[0]
        @unblock()
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        # HTTP.get "https://en.wikipedia.org/w/api.php?action=query&format=json&list=users&usprop=blockinfo%7Cgroups%7Ceditcount%7Cregistration%7Cemailable%7Cgender&ususers=1.2.3.4%7CCatrope%7CVandal01%7CBob}",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=query&list=search&srwhat=text&srsearch=meaning&format=json",(err,response)=>
            if err
                console.log err
            unless err
                console.log response.data
                # for term,i in response.data[1]
                #     url = response.data[3][i]
    
    search_wiki: (query)->
        # term = query.split(' ').join('_')
        # term = query[0]
        @unblock()
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        # HTTP.get "https://en.wikipedia.org/w/api.php?action=query&list=search&srwhat=text&srsearch=#{term}&searchformat=json",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=opensearch&generator=searchformat=json&search=#{term}",(err,response)=>
        # HTTP.get "https://en.wikipedia.org/w/api.php?action=query&list=search&srwhat=text&srsearch=#{term}&format=json",(err,response)=>
            if err
                console.log err
            unless err
                # console.log response
                for term,i in response.data[1]
                    url = response.data[3][i]
                    # console.log response.data[3]
                    # console.log term, 'term'
                    found_doc =
                        Docs.findOne
                            url: url
                            model:'wikipedia'
                    if found_doc
                        Docs.update found_doc._id,
                            # $pull:
                            #     tags:'wikipedia'
                            $addToSet:
                                tags:term.toLowerCase()
                            $set:
                                title:found_doc.title.toLowerCase()
                        unless found_doc.metadata
                            Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                    else
                        new_wiki_id = Docs.insert
                            title:term.toLowerCase()
                            tags:[term.toLowerCase()]
                            source: 'wikipedia'
                            model:'wikipedia'
                            # ups: 1
                            url:url
                        Meteor.call 'call_watson', new_wiki_id, 'url','url', ->




Meteor.publish 'post_count', (
    picked_tags
    # picked_authors
    # picked_Locations
    # picked_times
    )->
    @unblock()
    match = {
        model:'wikipedia'
        # is_private:$ne:true
    }
    # unless Meteor.userId()
    #     match.privacy='public'

    if picked_tags.length > 0
        match.tags = $all:picked_tags
        # if picked_authors.length > 0 then match.author = $all:picked_authors
        # if picked_Locations.length > 0 then match.location = $all:picked_Locations
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        Counts.publish this, 'post_count', Docs.find(match)
        return undefined
            
Meteor.publish 'wposts', (
    picked_tags
    toggle
    picked_Locations
    # picked_Lo
    # picked_persons
    # sort_key='data.ups'
    # sort_direction=-1
    # limit=20
    # picked_times
    # picked_Locations
    # picked_authors
    # skip=0
    )->
        
    # @unblock()
    self = @
    match = {
        model:'wikipedia'
        # is_private:$ne:true
        # group:$exists:false
    }
    # unless Meteor.userId()
    #     match.privacy='public'
    
    # if sort_key
    #     sk = sort_key
    # else
    #     sk = '_timestamp'
    # if nsfw
    #     match['data.over_18'] = true
    # else
    # match['data.over_18'] = false
    
    if picked_tags.length > 0
        match.tags = $all:picked_tags
        if picked_Locations.length > 0 then match.location = $all:picked_Locations
        # if picked_authors.length > 0 then match['data.author'] = $all:picked_authors
        # if picked_domains.length > 0 then match['data.domain'] = $all:picked_domains
        # if picked_persons.length > 0 then match.Person = $all:picked_persons
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        Docs.find match,
            limit:20
            sort:
                "ups":-1
            # sort: "#{sort_key}":-1
            # skip:skip*20
        
    
           
Meteor.publish 'wtags', (
    picked_tags
    toggle
    picked_Locations
    picked_Persons
    picked_Companys
    picked_Organizations
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'wikipedia'
        # model:'post'
        # is_private:$ne:true
        # sublove:sublove
    }


    # unless Meteor.userId()
    #     match.privacy='public'
    # if nsfw
    #     match['data.over_18'] = true
    # else
    # match['data.over_18'] = false
    # if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_tags.length > 0
        match.tags = $all:picked_tags
        if picked_Locations.length > 0 then match.Location = $all:picked_Locations
        if picked_Persons.length > 0 then match.Person = $all:picked_Persons
        if picked_Companys.length > 0 then match.Company = $all:picked_Companys
        if picked_Organizations.length > 0 then match.Organization = $all:picked_Organizations

        doc_count = Docs.find(match).count()
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20  }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (wtag, i) ->
            self.added 'results', Random.id(),
                name: wtag.name
                count: wtag.count
                model:'wtag'
        
        Location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Location": 1 }
            { $unwind: "$Location" }
            { $group: _id: "$Location", count: $sum: 1 }
            { $match: _id: $nin: picked_Locations }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        Location_cloud.forEach (Location, i) ->
            self.added 'results', Random.id(),
                name: Location.name
                count: Location.count
                model:'Location'
        
        
        Person_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Person": 1 }
            { $unwind: "$Person" }
            { $group: _id: "$Person", count: $sum: 1 }
            { $match: _id: $nin: picked_Persons }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        Person_cloud.forEach (Person, i) ->
            self.added 'results', Random.id(),
                name: Person.name
                count: Person.count
                model:'Person'
        
        Company_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Company": 1 }
            { $unwind: "$Company" }
            { $group: _id: "$Company", count: $sum: 1 }
            { $match: _id: $nin: picked_Companys }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        Company_cloud.forEach (Company, i) ->
            self.added 'results', Random.id(),
                name: Company.name
                count: Company.count
                model:'Company'
        
                
        Organization_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Organization": 1 }
            { $unwind: "$Organization" }
            { $group: _id: "$Organization", count: $sum: 1 }
            { $match: _id: $nin: picked_Organizations }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        Organization_cloud.forEach (Organization, i) ->
            self.added 'results', Random.id(),
                name: Organization.name
                count: Organization.count
                model:'Organization'
        
        
        
        self.ready()
        
    


Meteor.publish 'wiki_doc', (
    # doc_id
    picked_tags
    )->
    # console.log 'dummy', dummy
    # console.log 'publishing wiki doc', picked_tags
    @unblock()
    self = @
    match = {}

    match.model = 'wikipedia'
    match.title = $in:picked_tags
    # console.log 'query length', query.length
    # if picked_tags.length > 1
    #     match.tags = $all: picked_tags
        
    Docs.find match,
        fields:
            title:1
            "analyzed_text":1
            url:1
            "metadata":1
            tags:1
            model:1
