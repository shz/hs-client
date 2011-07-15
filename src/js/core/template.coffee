
dep.require 'hs'
dep.require 'CoffeeKup'
dep.require 'zz.models'
dep.require 'hs.EventEmitter'

dep.provide 'hs.Template'


class hs.Template extends hs.EventEmitter

  templateLocals: {}
  injected: false
  _meta: []
  initListeners: []
  modInit: ->

  constructor: (@model, @options = {}) ->
    this.modInit()

    this.emit('preConstructor')
    this._moveOptions()
    this._setupTemplates()
    this._init()
    this.emit('postConstructor')


  _moveOptions: ->
    if this.options.prependTo? then this.prependTo = this.options.prependTo
    if this.options.appendTo? then this.appendTo = this.options.appendTo
    if this.options.nthChild? then this.nthChild = this.options.nthChild
    if this.options.parent? then this.parent = this.options.parent

    if this.options.id?
      this.id = this.options.id

    else if not this.id?
      this.id = this.constructor.name

      if this.model?._id?
        this.id += "-#{this.model._id}"


  _init: ->
    if this.init?
      this.init => this.render()
    else
      this.render()


  _setupTemplates: ->
    if this.templates?
      throw new Error '_setupTemplates should only be called once'

    this.templates = []
    for name, classOpts of this.subTemplates then do (name, classOpts) =>

      method = "#{name}Tmpl"

      this[method] = (model, instOpts) =>
        opts = _.extend {parent: this}, classOpts, instOpts

        tmpl = new classOpts.class model, opts

        if not opts.nthChild?
          this.templates.push tmpl

        else
          this.templates.splice opts.nthChild, 1, tmpl

        this.emit 'subTemplateAdd', tmpl, opts.nthChild

      this[method].remove = () =>
        for tmpl, i in this.templates
          if tmpl.constructor.name == name
            tmpl.remove()
            this.templates.splice i, 1

            this.emit 'subTemplateRemove', i


  removeTmpl: (index) ->
    if not this.templates[index]?
      throw new Error 'Invalid sub-template index'

    this.templates[index].remove()
    this.templates.splice index, 1

    this.emit 'subTemplateRemove', index


  _renderTemplate: ->
    this.el = $ "##{this.id}"

    if this.el.length == 0
      html = CoffeeKup.render this.template,
        context: this
        locals: this.templateLocals
        cache: off

      this.el = $(html)
      this.el.attr 'id', this.id

    else
      this.injected = true

    this.$ = (selector) => $ selector, this.el


  _insertTemplate: ->
    return if this.injected

    if this.appendTo?
      if not this.nthChild?
        $(this.appendTo).append this.el

      else
        $("#{this.appendTo}:nth-child(#{this.nthChild})").after this.el

      this.injected = true

    else if this.prependTo?
      $(this.prependTo).prepend this.el
      this.injected = true


  _listenOnModel: ->
    if this.model?
      this.model.heat()

      if _.isArray this.model #model list
        if this.addModel?
          this.model.on 'add', => this.addModel.apply this, arguments
        if this.removeModel?
          this.model.on 'remove', => this.removeModel.apply this, arguments

      else
        for own field of this.model
          method = 'set'+ field.charAt(0).toUpperCase() + field.slice(1)

          if this[method]?
            this.model.on field, => this[method].apply(this, arguments)
            this[method] this.model[field]


  render: ->
    this.emit('preRender')
    this.preRender?()

    this._renderTemplate()
    this._insertTemplate()
    this._listenOnModel()

    this.postRender?()
    this.emit('postRender')


  meta: (props) ->
    meta = $ '<meta>'

    for key, val of props
      meta.attr key, val

    this._meta.push meta


  _removeMeta: -> meta.remove() for meta in this._meta


  authChange: (prev, cur) ->
    this.setAuth?(prev, cur)
    this.emit 'setAuth', prev, cur
    tmpl.authChange prev, cur for tmpl in this.templates


  remove: ->
    this.emit('preRemove')
    this.preRemove?()

    sub.remove() for sub in this.templates

    this.el?.remove()
    this.el = null
    this.$ = null
    this._removeMeta()
    this.model?.freeze()

    this.postRemove?()
    this.emit('postRemove')


hs.Template.get = (options, clbk) ->
  user = zz.auth.curUser()
  if this.getModel?
    this.getModel options, (model) =>
      template = new this(model, options)
      template.authChange null, user
      clbk template
  else
    template = new this(null, options)
    template.authChange null, user
    clbk template