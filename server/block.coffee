# lang
# mkdgRJwYEJnuJUhCv0Ny7REL4scA27el5mdPKrnGMEMg


# kevin lang
# bsbqj-_iQaA-ZwGUBK7NbGqZTaLvPHJgZW2OEXoN5C6P
# https://api.us-south.natural-language-understanding.watson.cloud.ibm.com/instances/5556901d-0bb1-4283-a2e3-d4cd8c42d15c


# tone
# QEDjdS8Btn2Qq1IFKWu1wirCfdCziCEJhaWt_Tn5MY87
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/6755dca9-6933-4529-81df-a985e6447170

# wDsUCpvjNiwBjDs5C1GvHwb970BDHBOcah_KXs-boFgG
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/6755dca9-6933-4529-81df-a985e6447170

# tone
# pIDLJyNdM8r4AB0lLmMNdGZtPSWUD3wXQfmXFBWxJ_l
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/37f08ca3-6c5b-439e-8270-78d96b54d635
# nlu
# WfilOI8O3M5n3cbU8byEczW_hctUm4viZDVaBSV-Gju3
# https://api.us-south.natural-language-understanding.watson.cloud.ibm.com/instances/b5195ac7-a729-46ea-b099-deb37d1dc65b

#


@blocklist = [
    'main articles'
    '2003 singles'
    '2008 singles'
    '2008 albums'
    '2000 singles'
    'view entire discussion'
    'sign up'
    'trademark'
    'reddit inc.'
    'adult content'
    'use of this site'
    'pages'
    '.inc'
    'following year'
    'terms of use'
    'additional terms'
    'registered trademark of the wikimedia foundation'
    'disambiguation page lists  articles'
    'site'
    'utc'
    'text'
    'privacy policy'
    'intended article'
    'disambiguation page lists articles'
    'non-profit organization'
    'page'
    'wikipedia'
    'internal link'
    'disambiguation page lists articles'
    'wikimedia foundation, inc.'
    'creative commons attribution-sharealike license'
    'technology and computing'
    'web search'
    'internet technology'
    'social network'
    'society'
    'reddit app reddit'
    'reddit post'
    'user account menu'
    'reddit premium reddit'
    'reddit inc'
    'english-language films'
    'bit'
    'moderators of this subreddit'
    'main article'
    'facebook pages'
    'personal attacks'
    'full article'
    'lot'
    'list'
    'blocklist'
    'browser extension'
    'reddit'
    'reason'
    'sub rules'
    'case sensitive'
    'question'
    'sub'
    'blog'
    # 'example'
    # 'person'
    # 'work'
    'times'
    # 'guys'
    'answer'
    'social media'
    'post facebook comments'
    'rights'
    'old embed code'
    'first time'
    'love imgur'
    'thanks'
    'original post'
    'hours'
    'following post'
    'mods'
    'original comment'
    'troll accusations'
    'career-related posts'
    'advertise blog'
    'last year'
    'guy'
    'man'
    'us'
    'questions'
    'month'
    'community'
    'discussion'
    'moderator'
    'post'
    'link'
    'links'
    'week'
    'month'
    'thing'
    'internet'
    'related articles'
    'reddit'
    'place'
    'feb'
    'thing'
    'careers press'
    '#'
    'articles'
    'comment  share'
    'things'
    'stickied'
    'original poster'
    'people'
    'days'
    'months'
    'members'
    'imgur'
    'careers press'
    'points'
    'comment'
    'comment share'
    'subreddit'
    'bot'
    'luser'
    'blog terms'
    'hide report'
    'hide  report'
    'copyright'
    'thread'
    'debut albums'
    '2000s music groups'
    'Facebook'
    'Twitter'
    'facebook'
    'twitter'
    'google'
    'Google'
    '2000 albums'
    '2001 albums'
    '2002 albums'
    '2003 albums'
    '2004 albums'
    '2005 albums'
    '2006 albums'
    '2007 albums'
    '2008 albums'
    '2009 albums'
    '2010 albums'
    '2006 singles'
    '2007 singles'
    '2005 singles'
    '2004 singles'
    '2008 singles'
    '2009 singles'
    'comments share'
    'comments  share'
    'new comments'
    'login'
    'shit'
    'cunt'
    'fuck'
    'help'
    'press j'
    'press question mark'
    'comment log'
    'comments'
    'way'
    'user'
    'communities'
    'point'
    'reddit'
    'original submission'
    'title'
    'term'
    'active discord community'
    'active players'
    'discord'
    'network of subreddits'
    'days'
    'blog terms'
    'sign'
    'level'
    'gif'
    'content of this sub'
    'view discussions'
    'content'
    'community moderation bot'
    'votes'
    'careers press'
    'feed'
    'hide report'
    'reactiongifs community'
    'entire discussion'
    'acceptance of our user agreement'
    'blog terms'
    'alien logo'
    'trademarks of reddit'
    'all rights reserved'
    'policy'
    'keyboard shortcut'
    'rest of the keyboard shortcuts'
    'login'
    "'s"
    '#'
    'hide report'
    'join'
    'posts'
    'top posts topics'
    'day'
    'reddit premium reddit gifts'
    'good bot moderator'
    'blog terms'
    'Reddit'
    'Reddit Inc'
]


Meteor.methods
    flatten: =>
        match = {
            model:'reddit'
            flattened:$ne:true
        }
        todo = Docs.find(match,{limit:100})
        for doc in todo.fetch()
            new_tags = _.flatten(doc.tags)
            Docs.update doc._id,
                $set:
                    flattened:true
                    tags:new_tags

    
    clear_blocklist: =>
        for black_tag in @blocklist

            result = Docs.update({tags:$in:[black_tag]}, {$pull:tags:black_tag}, {multi:true})

    clear_blocklist_doc: (doc_id)=>
        Docs.update doc_id,
            $pullAll:
                tags:@blocklist