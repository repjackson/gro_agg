    
# Meteor.methods
#     tagify_time_rpost: (doc_id)->
#         doc = Docs.findOne doc_id
#         # moment.unix(doc.data.created).fromNow()
#         # timestamp = Date.now()

#         doc._timestamp_long = moment.unix(doc.data.created).format("dddd, MMMM Do YYYY, h:mm:ss a")
#         # doc._app = 'dao'
    
#         date = moment.unix(doc.data.created).format('Do')
#         weekdaynum = moment.unix(doc.data.created).isoWeekday()
#         weekday = moment().isoWeekday(weekdaynum).format('dddd')
    
#         hour = moment.unix(doc.data.created).format('h')
#         minute = moment.unix(doc.data.created).format('m')
#         ap = moment.unix(doc.data.created).format('a')
#         month = moment.unix(doc.data.created).format('MMMM')
#         year = moment.unix(doc.data.created).format('YYYY')
    
#         # doc.points = 0
#         # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
#         date_array = [ap, weekday, month, date, year]
#         if _
#             date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
#             doc._timestamp_tags = date_array
#             Docs.update doc_id, 
#                 $set:time_tags:date_array
                        
