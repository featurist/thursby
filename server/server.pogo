express = require 'express'
bodyParser = require 'body-parser'
fs = require 'fs'

app = express ()

app.use (bodyParser.urlencoded (extended: false))
app.use (express.static 'public')

app.get '*' @(req, res)
  fs.readFile "#(__dirname)/../public/index.html" 'utf8' @(err, html)
    res.send(html)

app.listen (process.env.PORT || 3001)
