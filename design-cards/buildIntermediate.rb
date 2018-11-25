#!/usr/bin/ruby

require 'nokogiri'
require 'json'

def readJson
    file = open('src/cards.json')
    json = file.read
    return JSON.parse(json)
end

def createCardSvg(card, colors)
    doc = File.open("src/card.svg") { |f| Nokogiri::XML(f) }
    lib = File.open("src/lib.svg") { |f| Nokogiri::XML(f) }

    setSingleLineText doc, 'abbreviation', card["abbreviation"]
    setSingleLineText doc, 'title', "#{card["abbreviation"]}: #{card["name"]}"
    setMultiLineText doc, 'short', "»#{card["short"]}«"
    setMultiLineText doc, 'long', card["long"]
    setSingleLineText doc, 'links', card["links"]
    setCardSet doc, lib, card['set']
    setShield doc, lib, card['shield']
    adjustColors doc, card, colors

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

def adjustColors(doc, card, colors)
    replaceColors doc, colors['simple']['background'], colors[card['shield']]['background'] 
    replaceColors doc, colors['simple']['line'], colors[card['shield']]['line'] 

    title = doc.at_xpath("//*[@id='text_title']/svg:tspan") 
    title['style'] = title['style'].gsub /#ffffff/, colors[card['shield']]['title']
end

def replaceColors(doc, srcColor, replacementColor)
    stylableNodes = doc.xpath("//*[@style]")
    stylableNodes.each do |node|
        node['style'] = node['style'].gsub /#{srcColor}/, replacementColor
    end
end

config = readJson()
config["cards"].each do |card|
    createCardSvg card, config['colors']
end
