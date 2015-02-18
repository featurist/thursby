plastiq = require 'plastiq'
h = plastiq.html
pogo = require 'pogo'
Firebase = require 'firebase'

firebaseRef = @new Firebase("https://thursby.firebaseio.com/")

firebaseChanged (refresh) =
  firebaseRef.on "value" @(snapshot)
    console.log ("GOT FIREBASE MODEL")
    model.data = snapshot.val().data
    model.parsedData = snapshot.val().parsedData
    model.code = snapshot.val().code
    model.compiledCode = @new Function('h','data',model.code)
    
    refresh()

tryParse(data) =
  try
    JSON.parse(data)
  catch (ex)
    nil

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
            catch (e)
              model.compiledCode () =
                h 'pre' 'ERROR: ' (e.toString())

            nil
                
        }
      }
      h 'br'
      h 'button' {style = {marginBottom = '20px'}, onclick() =
        firebaseRef.update(code: model.code)
      } 'Save code'
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
              firebaseRef.update(data: model.data, parsedData: model.parsedData)

            if (!parsed || JSON.stringify(model.parsedData) == JSON.stringify(parsed))
              model.data
            else
              model.data = JSON.stringify(model.parsedData, null, 2)

          set(data) =
            model.data = data
            parsed = tryParse(model.data)
            
            try
              model.parsedData = JSON.parse(data)
              model.error = nil
            catch (ex)
              model.error = ex

            firebaseRef.update(data: model.data, parsedData: model.parsedData)
        }
      }
    )
    h '.render' (
      h 'label' 'render'
      h 'div' (
        try
          model.compiledCode(h, model.parsedData)
        catch (ex)
          model.error = ex
          ''
      )
      h 'alert alert-error', model.error && model.error.message
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
