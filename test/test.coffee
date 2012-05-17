fs = require 'fs'
root = "#{__dirname}/../"
should = require 'should'
Template = require "#{root}src/template"

templateFolder = "#{root}templates/"
templates = fs.readdirSync templateFolder
sampleFolder = "#{root}samples/"
samples = fs.readdirSync sampleFolder
expectFolder = "#{root}expect/"

for templateFilename in templates
  do (templateFilename) ->
    matches = templateFilename.match /^([a-z]+)\.([a-z]+)$/
    if !matches
      console.log "Skipping '#{templateFilename}'"
      return
    [ignore,name,type] = matches
    describe name, ->
      templateString = fs.readFileSync templateFolder+templateFilename, 'utf8'
      testSamples = []
      for sampleFilename in samples
        if sampleFilename.substr(0,Math.min(sampleFilename.length, name.length+1)) is "#{name}."
          testSamples.push sampleFilename
      it 'should have tests', ->
        testSamples.should.not.be.empty
      for testSampleFilename in testSamples
        do (testSampleFilename) ->
          sampleJSON = fs.readFileSync sampleFolder + testSampleFilename, 'utf8'
          data = null
          it "should have valid sample data", ->
            data = JSON.parse sampleJSON
          expect = null
          try
            expect = fs.readFileSync expectFolder + testSampleFilename + ".txt", 'utf8'
            expect = expect.replace /\n$/, ""
          catch e
            console.warn "WARNING: No expected output file for '#{testSampleFilename}'"
          it "should have expected output '#{expectFolder + testSampleFilename + ".txt"}'", ->
            should.exist expect
          it "should correctly render #{testSampleFilename}", (next) ->
            Template.dust templateString, data, (err, output) ->
              should.not.exist(err)
              should.exist(output)
              output = output.replace /\n$/, ""
              output.should.eql(expect)
              next()
