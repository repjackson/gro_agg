if Meteor.isClient
    Template.question_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'question_answers', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'all_questions'
  
    Template.question_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'question_answers', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'all_questions'
  
    Template.question_edit.onRendered ->
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 2000

    Template.question_view.onRendered ->
        # Meteor.call 'log_view', Router.current().params.doc_id
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 2000
        # Meteor.setTimeout ->
        #     $('.ui.embed').embed();
        # , 1000
        # Meteor.call 'mark_read', Router.current().params.doc_id, ->
    Template.question_edit.helpers
        subtotal: -> @bounties_available*@points_per_answer
    Template.question_view.helpers
        question_answers: ->
            Docs.find 
                model:'answer'
                question_id:Router.current().params.doc_id
        # dependencies: ->
        #     Docs.find 
        #         model:'question'
        #         dependency_ids:$in:[Router.current().params.doc_id]
        #         question_id:Router.current().params.doc_id
    Template.question_view.events
        'click .add_answer': ->
            new_id = Docs.insert 
                model:'answer'
                question_id:Router.current().params.doc_id
                published:false
            Session.set('editing_answer_id', new_id)    
                
        'click .add_dependency': ->
            new_id = Docs.insert 
                model:'question'
                dependency_ids:[Router.current().params.doc_id]
                published:false
            Router.go "/question/#{new_id}/edit"
            Session.set('editing_answer_id', new_id)    
                
                
    
    Template.question.helpers
        vote_true_class: ->
            if @voter_true_ids and Meteor.userId() in @voter_true_ids then 'active' else 'basic'
        vote_false_class: ->
            if @voter_false_ids and Meteor.userId() in @voter_false_ids then 'active' else 'basic'
        vote_true_icon_class: ->
            if @voter_true_ids and Meteor.userId() in @voter_true_ids then 'green invert' else 'outline'
        vote_false_icon_class: ->
            if @voter_false_ids and Meteor.userId() in @voter_false_ids then 'red invert' else 'outline'
    Template.question.events
        'click .vote_true': ->
            Docs.update @_id, 
                $addToSet:
                    voter_true_ids: Meteor.userId()
                $pull:
                    voter_false_ids: Meteor.userId()
                    
        'click .vote_false': ->
            Docs.update @_id, 
                $addToSet:
                    voter_false_ids: Meteor.userId()
                $pull:
                    voter_true_ids: Meteor.userId()
                    
    

                
    
if Meteor.isClient
    Template.question_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.question_edit.events
        'click .delete_question': ->
            Swal.fire({
                title: "delete question?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'question removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/"
            )
            
            
            
if Meteor.isServer
    Meteor.publish 'question_answers', (question_id)->
        Docs.find 
            model:'answer'
            question_id:question_id
            
    Meteor.publish 'all_questions', (question_id)->
        Docs.find 
            model:'question'
            # question_id:question_id
            
            