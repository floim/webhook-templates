crypto = require 'crypto'
Dust = require './dust'

sha1 = (str) ->
  shasum = crypto.createHash 'sha1'
  shasum.update str
  return shasum.digest('base64')

exports.buildDust = (templateString, name) ->
  return Dust.compile templateString, name

cachedDustTemplates = {}

exports.dust = (templateString, data, callback) ->
  id = sha1 templateString
  unless cachedDustTemplates[""+id]
    try
      cachedDustTemplates[""+id] = Dust.compileFn templateString
    catch e
      callback e
      return
  template = cachedDustTemplates[""+id]
  try
    template Dust.dustBase.push(data), callback
  catch e
    callback e
    return
  return
