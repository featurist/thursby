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

  firebaseRef.child("parsedData").on "value" @(snapshot)
    console.log ("GOT FIREBASE CODE")
    model.parsedData = snapshot.val()
    refresh()

tryParse(data) =
  try
    JSON.parse(data)
  catch (ex)
    "Invalid JSON"

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
              model.compiledCode = @new Function('h','data',code)
              firebaseRef.set(code: model.code, data: model.data, parsedData: model.parsedData)
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
          get() = 
            parsed = tryParse(model.data)
            if (model.code && model.data && model.parsedData)
              firebaseRef.set(code: model.code, data: model.data, parsedData: model.parsedData)

            if (JSON.stringify(model.parsedData) == JSON.stringify(parsed))
              model.data
            else
              model.data = JSON.stringify(model.parsedData, null, 2)

          set(data) =
            model.data = data
            model.parsedData = tryParse(model.data)
            firebaseRef.set(code: model.code, data: model.data, parsedData: model.parsedData)
        }
      }
    )
    h '.render' (
      h 'label' 'render'
      h 'div' (
        try
          model.compiledCode(h, model.parsedData)
        catch (ex)
          h ('span.error', ex.message)
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
