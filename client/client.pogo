plastiq = require 'plastiq'
h = plastiq.html
pogo = require 'pogo'
Firebase = require 'firebase'

firebaseRef = @new Firebase("https://thursby.firebaseio.com/")

firebaseChanged (refresh) =
  firebaseRef.on "value" @(snapshot)
    value = snapshot.val()
    console.log ("GOT MODEL FROM FIREBASE", value)
    model.data = value.data
    model.parsedData = value.parsedData
    model.code = value.code
    model.compiledCode = @new Function('h', 'data', model.code)

    refresh()

tryParse(data) =
  try
    JSON.parse(data)
  catch (ex)
    nil

renderApp (model) =
  h '.app' (
    h.animation(firebaseChanged)
    h '.user' (
      h 'img.avatar' {
        src = model.authData.github.cachedUserProfile.avatar_url
      }
      h '.name' (model.authData.github.displayName)
      h 'a.logout' {
        href = '#logout'
        onclick(e) =
          e.preventDefault()
          firebaseRef.unauth()
      } 'Logout'
    )
    h '.code' (
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
      h 'button.save-code' {
        onclick() =
          firebaseRef.update(code: model.code)
      } 'Save Code'
    )
    h '.data' (
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
    h 'button.login' { onclick () = model.authenticate() } 'Login with Github'

model = {
  authData = nil

  authenticate () =
    try
      self.authData = promise! @(fulfilled, rejected)
        if (self.authData)
          fulfilled(self.authData)
        else
          firebaseRef.authWithOAuthPopup "github" @(error, authData)
            fulfilled(authData)
            rejected(error)
    catch (e)
      self.authError = e
      rejected ()

  compiledCode () =
    h 'pre' '...'
}

firebaseRef.onAuth @(authData)
  model.authData = authData
  if (model.refresh)
    model.refresh ()

plastiq.attach (document.body, render, model)

// console convenience
window.model = model
window.firebaseRef = firebaseRef
