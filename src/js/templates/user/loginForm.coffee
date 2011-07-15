
dep.require 'hs.Template'
dep.require 'hs.t.mods.form'

dep.provide 'hs.t.LoginForm'


class hs.t.LoginForm extends hs.Template

  appendTo: '#top-bar > .width'

  fields: [{
      'name': 'email',
      'type': 'email',
      'placeholder': 'Email'
    },{
      'name': 'password',
      'type': 'password',
      'placeholder': 'Password'
  }]


  template: ->
    form ->
      fields()
      input type: 'submit', value: 'Submit', class: 'dark submit'



hs.t.mods.form hs.t.LoginForm
