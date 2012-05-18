fs = require 'fs'
root = "#{__dirname}/../"
should = require 'should'
Template = require "#{root}src/template"

templateFolder = "#{root}templates/"
templates = fs.readdirSync templateFolder
sampleFolder = "#{root}samples/"
samples = fs.readdirSync sampleFolder
expectFolder = "#{root}expect/"

WebhookTemplates = require "#{root}lib/webhook-templates"

for templateFilename in templates
  do (templateFilename) ->
    matches = templateFilename.match /^([a-z]+)\.([a-z]+)$/
    if !matches
      console.log "Skipping '#{templateFilename}'"
      return
    [ignore,name,type] = matches
    describe name, ->
      #templateString = fs.readFileSync templateFolder+templateFilename, 'utf8'
      testSamples = []
      for sampleFilename in samples
        if sampleFilename.substr(0,Math.min(sampleFilename.length, name.length+1)) is "#{name}."
          testSamples.push sampleFilename
      it 'should have compiled', ->
        WebhookTemplates.templateNames.indexOf(name).should.not.be.eql(-1)
        should.exist WebhookTemplates.templates[name]
      it 'should have test(s)', ->
        testSamples.should.not.be.empty
      for testSampleFilename in testSamples
        do (testSampleFilename) ->
          describe "test #{testSampleFilename}", ->
            sampleJSON = fs.readFileSync sampleFolder + testSampleFilename, 'utf8'
            data = null
            it "should be valid", ->
              data = JSON.parse sampleJSON
            expect = null
            try
              expect = fs.readFileSync expectFolder + testSampleFilename + ".txt", 'utf8'
              expect = expect.replace /\n$/, ""
            catch e
              console.warn "WARNING: No expected output file for '#{testSampleFilename}'"
            it "should have expected output '#{testSampleFilename + ".txt"}'", ->
              should.exist expect
            it "should correctly render '#{testSampleFilename}'", (next) ->
              WebhookTemplates.render name, data, (err, output) ->
              #Template.dust templateString, data, (err, output) ->
                should.not.exist(err)
                should.exist(output)
                output = output.replace /\n$/, ""
                output.should.eql(expect)
                next()
