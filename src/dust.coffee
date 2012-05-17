Dust = require 'dustjs-linkedin'
_ = require 'underscore'

# Uncomment next line to disable whitespace compression
# NOTE: Better is to use {~s} / {~n} / etc. instead.
#Dust.optimizers.format = (ctx, node) -> node

nth = (chunk, context, bodies, params, n) ->
  n = parseInt n
  if _.isArray(params.array) and !isNaN(n) and isFinite(n) and (n >= 0 or (n += params.array.length)>=0) and params.array.length > n
    return chunk.render bodies.block, context.push params.array[n]
  else if bodies['else']?
    return chunk.render bodies['else'], context
  else
    return chunk.write ""

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
    return nth chunk, context, bodies, params, 0
  last: (chunk, context, bodies, params) ->
    return nth chunk, context, bodies, params, -1
  reverse: (chunk, context, bodies, params) ->
    if _.isArray(params.array) and params.array.length
      for i in [params.array.length-1..0]
        chunk.render bodies.block, context.push params.array[i]
      return chunk
    else if bodies['else']?
      return chunk.render bodies['else'], context
    else
      return chunk.write ""
Dust.dustBase = dustBase

oldRender = Dust.render
Dust.render = (name, data, callback) ->
  oldRender name, dustBase.push(data), callback

module.exports = Dust
