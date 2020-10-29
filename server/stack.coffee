request = require('request')
Meteor.methods 
    search_stack: (query, selected_tags) ->
        console.log('searching stack for', typeof(query), query);
        # var url = 'https://api.stackexchange.com/2.2/sites';
        # url = 'http://api.stackexchange.com/2.1/questions?pagesize=1&fromdate=1356998400&todate=1359676800&order=desc&min=0&sort=votes&tagged=javascript&site=stackoverflow'
        # url = "http://api.stackexchange.com/2.1/questions?pagesize=10&order=desc&min=0&sort=votes&tagged=#{selected_tags}&intitle=#{query}&site=stackoverflow"
        # url = "http://api.stackexchange.com/2.1/questions?pagesize=10&order=desc&min=0&sort=votes&intitle=#{query}&site=stackoverflow"
        url = "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=#{query}&site=stackoverflow"
        request.get {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }, Meteor.bindEnvironment((error, response, body) =>
            parsed = JSON.parse(body)
            # console.log 'body',JSON.parse(body), typeof(body)
            for item in parsed.items
                found = 
                    Docs.findOne
                        model:'stack'
                        question_id:item.question_id
                if found
                    console.log 'found', found.title
                unless found
                    item.model = 'stack'
                    new_id = 
                        Docs.insert item
                    console.log 'new stack doc', Docs.findOne(new_id)
            return
        )
        return