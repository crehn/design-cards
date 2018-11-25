#!/usr/bin/ruby

require 'nokogiri'
require 'json'

def readJson
    file = open('src/cards.json')
    json = file.read
    return JSON.parse(json)
end

def createCardSvg(card)
    doc = File.open("src/card.svg") { |f| Nokogiri::XML(f) }

    setSingleLineText doc, 'abbreviation', card["abbreviation"]
    setSingleLineText doc, 'title', "#{card["abbreviation"]}: #{card["name"]}"
    setMultiLineText doc, 'short', card["short"]
    setMultiLineText doc, 'long', card["long"]
    setSingleLineText doc, 'links', card["links"]

    File.write("intermediate/#{card["abbreviation"]}.svg", doc) 
end

def setSingleLineText(doc, id, value)
    tspan = doc.at_xpath("//svg:tspan[@id='#{id}']")
    tspan.content = value
end

def setMultiLineText(doc, id, value)
    tspan = doc.at_xpath("//svg:flowPara[@id='#{id}']")
    tspan.content = value
end

cards = readJson()["cards"]
cards.each do |card|
    createCardSvg card
end
