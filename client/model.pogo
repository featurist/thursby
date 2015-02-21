Firebase = require 'firebase'

model = {

  firebaseRef = @new Firebase("https://thursby.firebaseio.com/")

  connectToFirebase () =
    self.firebaseRef.onAuth @(authData)
      self.authData = authData
      if (self.refresh)
        self.refresh ()

  firebaseChanged (refresh) =
    self.firebaseRef.on "value" @(snapshot)
      value = snapshot.val()
      model.data = value.data
      model.parsedData = value.parsedData
      model.code = value.code
      model.compiledCode = @new Function('h', 'data', model.code)

      refresh()
    @(error)
      alert "ACCESS DENIED (UID=#(window.authData.uid))"

  authData = nil

  authenticate () =
    try
      self.authData = promise! @(fulfilled, rejected)
        if (self.authData)
          fulfilled(self.authData)
        else
          self.firebaseRef.authWithOAuthPopup "github" @(error, authData)
            fulfilled(authData)
            rejected(error)
    catch (e)
      self.authError = e
      rejected ()

  compiledCode () =
    h 'pre' '...'

}

model.connectToFirebase ()

module.exports = model
