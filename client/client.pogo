plastiq = require 'plastiq'
model = require './model'
render = require './render'

// console convenience
window.model = model

plastiq.append (document.body, render, model)
