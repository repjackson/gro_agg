Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()

    # if @direct
    parent = Template.parentData()
    if parent
        parent["#{@key}"]



Template.registerHelper 'post_person', () ->
    # console.log @
    parent = Template.parentData()
        
    Docs.findOne
        model:'person'
        _id:@person_id



