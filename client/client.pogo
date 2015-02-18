plastiq = require 'plastiq'
h = plastiq.html
pogo = require 'pogo'
Firebase = require 'firebase'

firebaseRef = @new Firebase("https://thursby.firebaseio.com/")

firebaseChanged (refresh) =
  firebaseRef.child("data").on "value" @(snapshot)
    console.log ("GOT FIREBASE DATA")
    model.data = snapshot.val()
    refresh()

  firebaseRef.child("code").on "value" @(snapshot)
    console.log ("GOT FIREBASE CODE")
    model.code = snapshot.val()
    refresh()

renderApp (model) =
  h '.app' (
    h.animation(firebaseChanged)
    h '.code' (
      h 'label' 'code'
      h 'textarea' {
        rows = 10
        cols = 80
        binding = {
          get() = model.code
          set(code) =
            model.code = code
            try
              model.compiledCode = @new Function(code)
              firebaseRef.set(code: code)
            catch (e)
              model.compiledCode () =
                h 'pre' 'ERROR: ' (e.toString())
        }
      }
    )
    h '.data' (
      h 'label' 'data'
      h 'textarea' {
        rows = 10
        cols = 80
        binding = {
          get() = model.data
          set(data) =
            model.data = data
            firebaseRef.set(data: value)
        }
      }
    )
    h '.render' (
      h 'label' 'render'
      h 'div' (
        model.compiledCode()
      )
    )
  )

render (model) =
  model.refresh = plastiq.html.refresh

  if (model.authError)
    h 'pre' "AUTH ERROR: #(model.authError)"
  else if (model.authData)
    renderApp (model)
  else
    h 'button' { onclick () = model.authenticate() } 'Login'

model = {
  authenticate () =
    try
      self.authData = promise! @(fulfilled, rejected)
        firebaseRef.authWithOAuthPopup "github" @(error, authData)
          fulfilled(authData)
          rejected(error)
    catch (e)
      self.authError = e

  compiledCode () =
    h 'pre' '...'
}

plastiq.attach (document.body, render, model)
