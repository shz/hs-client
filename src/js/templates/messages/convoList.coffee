
dep.require 'hs.Template'
dep.require 'hs.t.ConvoLI'

dep.provide 'hs.t.ConvoList'

class hs.t.ConvoList extends hs.Template

  alwaysFresh: true

  template: -> """
    <div class="convo-list list-box">
      <div class="li no-cs">No Messages Yet.</div>
    </div>
    """


  subTemplates:
    convoLI:
      class: hs.t.ConvoLI
      appendTo: '.convo-list'

  preRender: -> $('.convo').remove()


  addModel: (convo, index) ->
    index = undefined if index == -1
    this.$('.no-cs').remove()
    this.convoLITmpl convo, {nthChild: index}


  removeModel: (id, index) -> this.removeTmpl index
