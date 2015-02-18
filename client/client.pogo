plastiq = require 'plastiq'
h = plastiq.html
pogo = require 'pogo'
Firebase = require 'firebase'

firebaseRef = @new Firebase("https://thursby.firebaseio.com/")

render (model) =
  model.refresh = plastiq.html.refresh

  if (model.authError)
    h 'pre' "AUTH ERROR: #(model.authError)"
  else if (model.authData)
    h 'pre' "AUTH DATA:\n#(JSON.stringify(model.authData))"
  else
    h 'button' {
      onclick () =
        firebaseRef.authWithOAuthPopup "github" @(error, authData)
          model.authError = error
          model.authData = authData
          model.refresh()
    } 'Login'


model = {}

plastiq.attach (document.body, render, model)
