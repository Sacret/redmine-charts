express = require 'express'
request = require 'request'

router = express.Router()

router.all '/api/*'
, (req, res, next) ->
  request
    uri: 'http://redmine.pfrus.com/' + req.params[0]
    method: req.method
    qs: req.query
  , (error, response, body) ->
    for header, value of response.headers
      continue if header == 'www-authenticate'
      res.header(header, value)
    return next(error) if error?
    unless 200 <= response.statusCode < 300
      err = new Error(response.headers.status)
      err.status = response.statusCode
      return next(err)
    res.status(response.statusCode).send(body)

module.exports = router
