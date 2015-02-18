plastiq = require 'plastiq'
h = plastiq.html
pogo = require 'pogo'
Firebase = require 'firebase'

firebaseRef = @new Firebase("https://thursby.firebaseio.com/")

render (model) =
  h '.soon' 'coming soon'

plastiq.attach (document.body, render, {})
