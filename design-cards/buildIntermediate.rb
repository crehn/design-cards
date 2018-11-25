#!/usr/bin/ruby

require 'nokogiri'
require 'json'

class Card
    attr_accessor :abbreviation, :name, :short, :long, :links, :set, :shield

    def initialize(params, config)
        params.each { |k,v| public_send("#{k}=",v) }
        @config = config
    end

    def title
        if symbolInConfig.nil? then
            return "#{@abbreviation}: #{@name}"
        else
            return @name
        end
    end

    def short 
        return "»#{@short}«"
    end

    def symbol
        if symbolInConfig.nil? then
            return @abbreviation
        else
            return symbolInConfig
        end
    end

    def symbolInConfig
        return @config['colors'][@shield]['symbol']
    end

    def font
        if symbolInConfig.nil?
            return 'Metamorphous'
        else
            return 'Liberation Serif'
        end
    end

    def fontSize
        if symbolInConfig.nil?
            return '14.81294632px'
        else
            return '24.1'
        end
    end
end

def readJson
    file = open('src/cards.json')
    json = file.read
    return JSON.parse(json)
end

def createCardSvg(card, colors)
    doc = File.open("src/card.svg") { |f| Nokogiri::XML(f) }
    lib = File.open("src/lib.svg") { |f| Nokogiri::XML(f) }

    setSingleLineText doc, 'abbreviation', card.symbol
    setSingleLineText doc, 'title', card.title
    setMultiLineText doc, 'short', card.short
    setMultiLineText doc, 'long', card.long
    setSingleLineText doc, 'links', card.links
    setCardSet doc, lib, card.set
    setShield doc, lib, card.shield
    adjustColors doc, card, colors
    setFont doc, 'abbreviation', card.font, card.fontSize

    File.write("intermediate/#{card.abbreviation}.svg", doc) 
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
    replaceColors doc, colors['simple']['background'], colors[card.shield]['background'] 
    replaceColors doc, colors['simple']['line'], colors[card.shield]['line'] 

    title = doc.at_xpath("//*[@id='text_title']/svg:tspan") 
    title['style'] = title['style'].gsub /#ffffff/, colors[card.shield]['title']

    marbleCircle = doc.at_xpath("//*[@id='card_set']//svg:circle[@transform]") 
    marbleCircle['style'] = marbleCircle['style'].gsub /fill:#[0-9a-f]+/, "fill:#{colors[card.shield]['marble']}"
end

def replaceColors(doc, srcColor, replacementColor)
    stylableNodes = doc.xpath("//*[@style]")
    stylableNodes.each do |node|
        node['style'] = node['style'].gsub /#{srcColor}/, replacementColor
    end
end

def setFont(doc, id, font, size)
    tspan = doc.at_xpath("//svg:tspan[@id='#{id}']")
    tspan['style'] = tspan['style'].gsub /font-family:'?[^';]*'?/, "font-family:'#{font}'"
    tspan['style'] = tspan['style'].gsub /-inkscape-font-specification:'?[^';]*'?/, "-inkscape-font-specification:'#{font}'"
    tspan['style'] = tspan['style'].gsub /font-size:[^';]*/, "font-size:#{size}"
end

config = readJson()
config["cards"].each do |card|
    createCardSvg Card.new(card, config), config['colors']
end

