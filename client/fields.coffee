Template.youtube_edit.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000

Template.youtube_view.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000


Template.youtube_edit.events
    'blur .youtube_id': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = t.$('.youtube_id').val()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val



Template.color_edit.events
    'blur .edit_color': (e,t)->
        val = t.$('.edit_color').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val



Template.html_edit.onRendered ->
    @editor = SUNEDITOR.create((document.getElementById('sample') || 'sample'),{
        # codeMirror: CodeMirror
        buttonList: [
            [
                'undo' 
                'redo'
                'font' 
                'fontSize' 
                'formatBlock' 
                'paragraphStyle' 
                'blockquote'
                'bold' 
                'underline' 
                'italic' 
                'strike' 
                'subscript' 
                'superscript'
                'fontColor' 
                'hiliteColor' 
                'textStyle'
                'removeFormat'
                'outdent' 
                'indent'
                'align' 
                'horizontalRule' 
                'list' 
                'lineHeight'
                'fullScreen' 
                'showBlocks' 
                'codeView' 
                'preview' 
                'table' 
                'image' 
                'video' 
                'audio' 
                'link'
            ]
        ]
        
        lang: SUNEDITOR_LANG['en']
    });

Template.html_edit.events
    'blur .testsun': (e,t)->
        html = t.editor.getContents(onlyContents: Boolean);

        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":html


Template.html_edit.helpers
        


Template.color_icon_edit.events
    'blur .color_icon': (e,t)->
        val = t.$('.color_icon').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val




Template.clear_value.events
    'click .clear_value': ->
        if confirm "Clear #{@title} field?"
            if @direct
                parent = Template.parentData()
            else
                parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1


Template.link_edit.events
    'blur .edit_url': (e,t)->
        val = t.$('.edit_url').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val


Template.icon_edit.events
    'blur .icon_val': (e,t)->
        val = t.$('.icon_val').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val


Template.image_edit.events
    "change input[name='upload_image']": (e) ->
        files = e.currentTarget.files
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) => #optional callback, you can catch with the Cloudinary collection as well
                if err
                    console.error 'Error uploading', err
                else
                    doc = Docs.findOne parent._id
                    if doc
                        Docs.update parent._id,
                            $set:"#{@key}":res.public_id

    'click .call_cloud_visual': (e,t)->
        Meteor.call 'call_visual', Router.current().params.doc_id, 'cloud', ->
            $('body').toast(
                showIcon: 'dna'
                message: 'image autotagged'
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom center"
            )


    'blur .cloudinary_id': (e,t)->
        cloudinary_id = t.$('.cloudinary_id').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        Docs.update parent._id,
            $set:"#{@key}":cloudinary_id


    'click #remove_photo': ->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        if confirm 'Remove Photo?'
            # Docs.update parent._id,
            #     $unset:"#{@key}":1
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1






Template.array_edit.events
    'click .pick_tag': (e,t)->
        console.log @
        selected_family_tags.push @valueOf()
        Router.go "/"
    'keyup .new_element': (e,t)->
        if e.which is 13
            element_val = t.$('.new_element').val().trim().toLowerCase()
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            Docs.update doc._id,
                $addToSet:"#{@key}":element_val
            t.$('.new_element').val('')

    'click .remove_element': (e,t)->
        element = @valueOf()
        field = Template.currentData()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $pull:"#{field.key}":element

        t.$('.new_element').focus()
        t.$('.new_element').val(element)


# Template.textarea.onCreated ->
#     @editing = new ReactiveVar false

# Template.textarea.helpers
#     is_editing: -> Template.instance().editing.get()


Template.textarea_edit.events
    # 'click .toggle_edit': (e,t)->
    #     t.editing.set !t.editing.get()

    'blur .edit_textarea': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":textarea_val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":textarea_val



Template.text_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val




Template.textarea_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000



Template.number_edit.events
    'blur .edit_number': (e,t)->
        # console.log @
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = parseInt t.$('.edit_number').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.float_edit.events
    'blur .edit_float': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = parseFloat t.$('.edit_float').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val
