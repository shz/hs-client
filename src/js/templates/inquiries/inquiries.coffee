
dep.require 'hs.Template'
dep.require 'zz'
dep.require 'hs.t.Inquiry'

dep.provide 'hs.t.Inquiries'

class hs.t.Inquiries extends hs.Template

  template: ->
    div class: 'inquiry-list', ->
      div class: 'li no-qs', -> 'No Questions Yet.'


  subTemplates:
    inquiry:
      class: hs.t.Inquiry
      appendTo: '.inquiry-list'


  addModel: (inquiry, index) ->
    index = undefined if index == -1
    this.$('.no-qs').remove()
    this.inquiryTmpl inquiry, {nthChild: index}


  removeModel: (id, index) ->
    this.removeTmpl index

