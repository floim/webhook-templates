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
    matches = templateString.match /^\{!WebhookTemplate\s*(\{[\s\S]*?[^!]\})\s*!\}/
    if matches
      try
        details = JSON.parse matches[1]
      catch e
        console.error "Could not parse details for '#{templateFilename}'"
        throw e
    else
      console.error "Invalid WebhookTemplate header for '#{templateFilename}'"
      return
    output.push "\ntemplateNames.push(#{JSON.stringify name});"
    output.push "templateDetails[#{JSON.stringify name}] = #{JSON.stringify details};"
    output.push "templateStrings[#{JSON.stringify name}] = #{JSON.stringify templateString};"
    code = Template.Dust.compile templateString, name
    output.push code

fs.unlinkSync "#{root}lib/template.js"
fs.unlinkSync "#{root}lib/webhook-templates.js"

src = coffee.compile fs.readFileSync("#{root}src/template.coffee", 'utf8'), {filename:"template.coffee",bare:true}
fs.writeFileSync "#{root}lib/template.js", src
output = """
  // Generated #{new Date().toUTCString()}
  Template = require('./template');
  dust = Template.Dust


  var templateNames = [];
  var templateDetails = {};
  var templateStrings = {};

  module.exports = Template
  module.exports.templateNames = templateNames;
  module.exports.templateDetails = templateDetails;
  module.exports.templateStrings = templateStrings;

  """+output.join("\n")
fs.writeFileSync "#{root}lib/webhook-templates.js", output
