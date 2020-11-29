Meteor.publish 'alpha_combo', (selected_tags)->
    Docs.find 
        model:'alpha'
        # query: $in: selected_tags
        query: selected_tags.toString()
        
# Meteor.publish 'alpha_single', (selected_tags)->
#     Docs.find 
#         model:'alpha'
#         query: $in: selected_tags
#         # query: selected_tags.toString()
        
        
Meteor.publish 'duck', (selected_tags)->
    Docs.find 
        model:'duck'
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
                                    
                                    
                            
    # add_chat: (chat)->
    #     @unblock()
    #     # now = Date.now()
    #     # found_last_chat = 
    #     #     Docs.findOne { 
    #     #         model:'global_chat'
    #     #         _timestamp: $lt:now
    #     #     }, limit:1
    #     # new_id = 
    #     #     Docs.insert 
    #     #         model:'global_chat'
    #     #         body:chat
    #     #         bot:false
    #     HTTP.get "http://api.wolframalpha.com/v1/conversation.jsp?appid=UULLYY-QR2ALYJ9JU&i=#{chat}",(err,res)=>
    #         if res
    #             parsed = JSON.parse(res.content)
    #             Docs.insert
    #                 model:'global_chat'
    #                 bot:true
    #                 res:parsed
    #             return parsed
                
                
    arespond: (post_id)->
        # @unblock()
        post = Docs.findOne post_id
        # now = Date.now()
        # found_last_chat = 
        #     Docs.findOne { 
        #         model:'global_chat'
        #         _timestamp: $lt:now
        #     }, limit:1
        # new_id = 
        #     Docs.insert 
        #         model:'global_chat'
        #         body:chat
        #         bot:false
        HTTP.get "http://api.wolframalpha.com/v1/conversation.jsp?appid=UULLYY-QR2ALYJ9JU&i=#{post.body}",(err,response)=>
            if response
                parsed = JSON.parse(response.content)
                Docs.insert
                    model:'alpha_response'
                    bot:true
                    response:parsed
                    parent_id:post_id
