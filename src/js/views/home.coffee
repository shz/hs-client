
dep.require 'hs.View'


class hs.v.Home extends hs.View

  init:->
    this.scroll = _.bind this.scroll, this
    $(window).bind 'scroll', this.scroll


  preRemove: -> $(window).unbind 'scroll', this.scroll


  scroll: (e)->
    if not this.template.scrollDone and
        $(window).scrollTop() + $(window).height() > this.template.scrollTrigger
      this.template.renderListings()
