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
      onclick () = model.authenticate()
    } 'Login'


model = {
  authenticate () =
    try
      self.authData = promise! @(fulfilled, rejected)
        firebaseRef.authWithOAuthPopup "github" @(error, authData)
          fulfilled(authData)
          rejected(error)
    catch (e)
      self.authError = e

}

plastiq.attach (document.body, render, model)
