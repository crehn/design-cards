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
    lib = File.open("src/lib.svg") { |f| Nokogiri::XML(f) }

    setSingleLineText doc, 'abbreviation', card["abbreviation"]
    setSingleLineText doc, 'title', "#{card["abbreviation"]}: #{card["name"]}"
    setMultiLineText doc, 'short', "»#{card["short"]}«"
    setMultiLineText doc, 'long', card["long"]
    setSingleLineText doc, 'links', card["links"]
    setCardSet doc, lib, card['set']
    setShield doc, lib, card['shield']

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

def setCardSet(doc, lib, set)
    card_set = doc.at_xpath("//svg:g[@id='card_set']") 
    card_set.children.remove
    set = lib.at_xpath("//svg:g[@id='#{set}_set']")
    card_set.add_child(set.children)
end

def setShield(doc, lib, value)
    shield = doc.at_xpath("//svg:g[@id='shield']") 
    shield.children.remove
    newShield = lib.at_xpath("//svg:g[@id='#{value}']")
    shield.add_child(newShield.children)
end

cards = readJson()["cards"]
cards.each do |card|
    createCardSvg card
end
