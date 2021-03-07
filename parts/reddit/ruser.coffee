
# if Meteor.isServer
#     Meteor.methods
#         get_user_posts: (username)->
#             # @unblock()s
#             # if subreddit 
#             #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
#             # else
#             url = "https://www.reddit.com/user/#{username}.json"
#             HTTP.get url,(err,res)=>
#                 if res.data.data.dist > 0
#                     _.each(res.data.data.children[0..100], (item)=>
#                         found = 
#                             Docs.findOne    
#                                 model:'rpost'
#                                 reddit_id:item.data.id
#                                 # subreddit:item.data.id
#                         # if found
#                         unless found
#                             item.model = 'rpost'
#                             item.reddit_id = item.data.id
#                             item.author = item.data.author
#                             item.subreddit = item.data.subreddit
#                             Docs.insert item
#                     )
        
#         get_user_comments: (username)->
#             # @unblock()s
#             # if subreddit 
#             #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
#             # else
#             url = "https://www.reddit.com/user/#{username}/comments.json"
#             HTTP.get url,(err,res)=>
#                 if res.data.data.dist > 0
#                     _.each(res.data.data.children[0..100], (item)=>
#                         found = 
#                             Docs.findOne    
#                                 model:'rcomment'
#                                 reddit_id:item.data.id
#                                 # subreddit:item.data.id
#                         # if found
#                         unless found
#                             item.model = 'rcomment'
#                             item.reddit_id = item.data.id
#                             item.author = item.data.author
#                             item.subreddit = item.data.subreddit
#                             Docs.insert item
#                     )
            
#                 # for post in res.data.data.children
#                 #     existing = 
#                 #         Docs.findOne({
#                 #             reddit_id: post.data.id
#                 #             model:'reddit'
#                 #         })
#                 #     # continue
#                 #     unless existing
#                 #     #     # if Meteor.isDevelopment
#                 #     #     # if typeof(existing.tags) is 'string'
#                 #     #     #     Doc.update
#                 #     #     #         $unset: tags: 1
#                 #     #     # Docs.update existing._id,
#                 #     #     #     $set: rdata:res.data.data
#                 #     #     continue
#                 #     # else
#                 #     #     # new_post = {}
#                 #     #     # new_post.model = 'reddit'
#                 #     #     # new_post.data = post.data
#                 #     #     # new_reddit_post_id = Docs.insert new_post
#                 #     #     continue
    
            
#         get_user_info: (username)->
#             # @unblock()s
#             # if subreddit 
#             #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
#             # else
#             url = "https://www.reddit.com/user/#{username}/about.json"
#             # url = "https://www.reddit.com/user/hernannadal/about.json"
#             options = {
#                 url: url
#                 headers: 
#                     # 'accept-encoding': 'gzip'
#                     "User-Agent": "web:com.dao.af:v1.2.3 (by /u/dontlisten65)"
#                 gzip: true
#             }
#             rp(options)
#                 .then(Meteor.bindEnvironment((data)->
#                     parsed = JSON.parse(data)
#                     existing = Docs.findOne 
#                         model:'ruser'
#                         username:username
#                     if existing
#                         Docs.update existing._id,
#                             $set:   
#                                 data:parsed.data
#                         # if Meteor.isDevelopment
#                         # if typeof(existing.tags) is 'string'
#                         # Docs.update existing._id,
#                         #     $set: rdata:res.data.data
#                     unless existing
#                         ruser = {}
#                         ruser.model = 'ruser'
#                         ruser.username = username
#                         # ruser.rdata = res.data.data
#                         new_reddit_post_id = Docs.insert ruser
#                 )).catch((err)->
#                 )
            
#             # HTTP.get url,(err,res)=>
#             #     # if res.data.data
    