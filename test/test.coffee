fs = require 'fs'
root = "#{__dirname}/../"
should = require 'should'
querystring = require 'querystring'
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
        WebhookTemplates.templateNames.should.include(name)
        should.exist WebhookTemplates.templateStrings[name]
        should.exist WebhookTemplates.templateDetails[name]
      it 'should have valid details', ->
        details = WebhookTemplates.templateDetails[name]
        details.name.should.be.a('string')
        details.author.should.be.a('string')
        ['JSON','form'].should.include details.format
        if details.jsonfield
          details.jsonfield.should.be.a('string')
        if details.ips
          details.ips.should.be.an.instanceof(Array)
          for ip in details.ips
            ip.should.be.a('string')
            ip.should.match /^([0-9]{1,3}\.){3}[0-9]{1,3}$/
        if details.url
          details.url.should.be.a('string')
          details.url.should.match /^https?:\/\/[^\/]+/
      it 'should have test(s)', ->
        testSamples.should.not.be.empty
      for testSampleFilename in testSamples
        do (testSampleFilename) ->
          describe "test #{testSampleFilename}", ->
            sampleData = fs.readFileSync sampleFolder + testSampleFilename, 'utf8'
            data = null
            it "should be valid", ->
              if testSampleFilename.match /\.json$/
                data = JSON.parse sampleData
              else if testSampleFilename.match /\.form$/
                data = querystring.parse sampleData.replace(/\s*$/,"")
              else
                throw new Error "Unknown type"
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
                output.should.equal(expect)
                next()
