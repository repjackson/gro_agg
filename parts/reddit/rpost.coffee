# if Meteor.isServer
#     Meteor.publish 'rpost_comment_tags', (
#         subreddit
#         parent_id
#         picked_tags
#         # view_bounties
#         # view_unanswered
#         # query=''
#         )->
#         # @unblock()
        
#         parent = Docs.findOne parent_id
        
#         self = @
#         match = {
#             model:'rcomment'
#             parent_id:"t3_#{parent.reddit_id}"
#         }
#         # if view_bounties
#         #     match.bounty = true
#         # if view_unanswered
#         #     match.is_answered = false
#         # if picked_tags.length > 0 then match.tags = $all:picked_tags
#         # if picked_emotion.length > 0 then match.max_emotion_name = picked_emotion
#         doc_count = Docs.find(match).count()
#         rpost_comment_cloud = Docs.aggregate [
#             { $match: match }
#             { $project: "tags": 1 }
#             { $unwind: "$tags" }
#             { $group: _id: "$tags", count: $sum: 1 }
#             { $match: _id: $nin: picked_tags }
#             { $sort: count: -1, _id: 1 }
#             { $match: count: $lt: doc_count }
#             { $limit:11 }
#             { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#         rpost_comment_cloud.forEach (tag, i) ->
#             self.added 'results', Random.id(),
#                 name: tag.name
#                 count: tag.count
#                 model:'rpost_comment_tag'
                
#         self.ready()
