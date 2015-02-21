plastiq = require 'plastiq'
h = plastiq.html
pogo = require 'pogo'

renderApp (model) =
  h '.app' (
    { class = model.layout }
    h.animation(model.firebaseChanged.bind(model))
    h '.header' (
      h '.edit-toggle' (
        if (model.layout == 'render-only')
          h 'a' {
            href = '#edit'
            onclick (e) =
              e.preventDefault()
              model.layout = 'edit'
          } 'Edit'
        else
          h 'a' {
            href = '#finish-editing'
            onclick (e) =
              e.preventDefault()
              model.layout = 'render-only'
          } 'Done'
      )
      h 'img.avatar' {
        src = model.authData.github.cachedUserProfile.avatar_url
      }
      h '.name' (model.authData.github.displayName)
      h 'a.logout' {
        href = '#logout'
        onclick(e) =
          e.preventDefault()
          model.firebaseRef.unauth()
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
          model.firebaseRef.update(code: model.code)
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
              model.firebaseRef.update(data: model.data, parsedData: model.parsedData)

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

            model.firebaseRef.update(data: model.data, parsedData: model.parsedData)
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

tryParse(data) =
  try
    JSON.parse(data)
  catch (ex)
    nil

module.exports = render
