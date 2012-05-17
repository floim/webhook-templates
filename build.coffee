fs = require 'fs'
root = "#{__dirname}/"
Template = require "#{root}src/template"

templateFolder = "#{root}templates/"
templates = fs.readdirSync templateFolder
sampleFolder = "#{root}samples/"
samples = fs.readdirSync sampleFolder
expectFolder = "#{root}expect/"

output = []
for templateFilename in templates
  do (templateFilename) ->
    matches = templateFilename.match /^([a-z]+)\.([a-z]+)$/
    if !matches
      console.log "Skipping '#{templateFilename}'"
      return
    [ignore,name,type] = matches
    templateString = fs.readFileSync templateFolder+templateFilename, 'utf8'
    output.push "\ntemplateNames.push(#{JSON.stringify name});"
    output.push "templates[#{JSON.stringify name}] = #{JSON.stringify templateString};"
    code = Template.buildDust templateString, name
    output.push code
output = """
  // Generated #{new Date().toUTCString()}
  require('coffee-script');
  dust = require('./src/dust');
  module.exports = dust
  var templateNames = [];
  var templates = {};
  module.exports.templateNames = templateNames;
  module.exports.templates = templates;

  """+output.join("\n")
fs.writeFileSync "#{root}webhook-templates.js", output
