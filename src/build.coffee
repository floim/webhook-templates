fs = require 'fs'
root = "#{__dirname}/../"
Template = require "#{root}src/template"
coffee = require 'coffee-script'

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
    code = Template.Dust.compile templateString, name
    output.push code

src = coffee.compile fs.readFileSync("#{root}src/template.coffee", 'utf8'), {filename:"template.coffee",bare:true}
fs.writeFileSync "#{root}lib/template.js", src
output = """
  // Generated #{new Date().toUTCString()}
  Template = require('./template');
  dust = Template.Dust


  var templateNames = [];
  var templates = {};

  module.exports = Template
  module.exports.templateNames = templateNames;
  module.exports.templates = templates;

  """+output.join("\n")
fs.writeFileSync "#{root}lib/webhook-templates.js", output
