Meteor.methods
    remove_doc: (doc_id)->
        Docs.remove doc_id

        

# Meteor.publish 'wikis', (
#     w_query
#     picked_tags
#     )->
#     Docs.find({
#         model:'wikipedia'
#     },{ 
#         limit:10
#     })
    


# Meteor.publish 'try', (title)->
#     Docs.find {
#         model:'rpost'
#     }, limit:10    

Meteor.publish 'doc_by_title', (title)->
    @unblock()
    Docs.find({
        title:title
        model:'wikipedia'
        "metadata.image":$exists:true
    }, {
        fields:
            title:1
            "metadata.image":1
            model:1
    })




Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
        
        
        
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> false
    update: (userId, doc) -> false
    remove: (userId, doc) -> false



Meteor.publish 'alpha_combo', (selected_tags)->
    @unblock()
    Docs.find 
        model:'alpha'
        # query: $in: selected_tags
        query: selected_tags.toString()
Meteor.methods
    call_alpha: (query)->
        # @unblock()
        found_alpha = 
            Docs.findOne 
                model:'alpha'
                query:query
        if found_alpha
            target = found_alpha
            # if target.updated
            #     return target
        else
            target_id = 
                Docs.insert
                    model:'alpha'
                    query:query
                    tags:[query]
            target = Docs.findOne target_id       
                   
                    
        HTTP.get "http://api.wolframalpha.com/v1/spoken?i=#{query}&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            if response
                Docs.update target._id,
                    $set:
                        voice:response.content  
            # HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=3&format=html,image,plaintext,sound&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=5&format=html,image,plaintext&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
                if response
                    parsed = JSON.parse(response.content)
                    Docs.update target._id,
                        $set:
                            response:parsed  
                            updated:true