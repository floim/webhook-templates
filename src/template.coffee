Dust = require 'dustjs-linkedin'
crypto = require 'crypto'
_ = require 'underscore'

# Uncomment next line to disable whitespace compression
# NOTE: Better is to use {~s} / {~n} / etc. instead.
#Dust.optimizers.format = (ctx, node) -> node

sha1 = (str) ->
  shasum = crypto.createHash 'sha1'
  shasum.update str
  return shasum.digest('base64')

dustBase = Dust.makeBase
  gitbranch: (chunk, context, bodies, params) ->
    if _.isString params.ref
      return chunk.write params.ref.replace(/^refs\/heads\//,"")
    return chunk
  gitshorthash: (chunk, context, bodies, params) ->
    if _.isString params.hash
      return chunk.write params.hash.substr(0,Math.min(7,params.hash.length))
    return chunk
  first: (chunk, context, bodies, params) ->
    if _.isArray(params.array) and params.array.length > 0
      return chunk.render bodies.block, context.push params.array[0]
    else if bodies['else']?
      return chunk.render bodies['else'], context
    else
      return chunk.write ""

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
    template dustBase.push(data), callback
  catch e
    callback e
    return
  return
