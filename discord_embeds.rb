require 'json'
require 'open-uri'
require 'nokogiri'
require 'metainspector'
require 'rss'
module Bot::DiscordCommands
  module News
    extend Discordrb::Commands::CommandContainer
    class Reader
        def initialize(id)
            @id = id
            @site = NewSites.new.get_site(id.to_i)
        end
        def id
            @id
        end
        def site
            @site
        end
        def info
            i = 0
            array = []
            rss = HTTParty.get(site[0], {headers: {"User-Agent" => "Guess What?"}}).body
            feed = RSS::Parser.parse(rss, false)
            feed.items.each do |item|
                if i.to_i <=  2
                    array += [[item.title, item.link, item.description.to_s.gsub("[...]", "")]]
                    p item.description
                    i += 1
                end
            end
        array
        end
    end
    class Lists
        def initialize
            @read = NewSites.new.read
        end
        def read
            @read 
        end
        def pretty_print
            sites_list = ""
            read.each do |key, value|
                sites_list += "#{key}] #{value[1]}\n"
            nil
            end
        sites_list
        end
        def json
            site_list = {}
            read.each do |key, value|
                site_list[key] = value[1]
            end
        site_list
        end
        def delete_by_id(id)
            i = 0
            j = JSON.parse(read.to_json)
            j.delete(id)
            array = j.to_a
            array.each do |l|
                l[0] = i.to_s
                i += 1
            end
        File.open("sites.json", "w") { |file| file.write(array.to_h.to_json) }
        end
        def add(url, name)
            json = read
            last = read.keys.last.to_i
            last += 1
            json[last] = [url, name]
            File.open("sites.json", "w") { |file| file.write(json.to_json) }
        end
    end
    class NewSites
        def read
            JSON.parse(File.read("sites.json"))
        end
        def get_site(id)
            read.each do |key, line|
                if key.to_s == "#{id}"
                    return line
                end
            end
        end
    end
    command(:news, description: "Get cyber news", usage: ".news 1 || .news ls") do |event, id, url, name|
        if id.to_s == "ls"
            event.respond(Lists.new.pretty_print.to_s)
        elsif ( id.to_s == "add"  || id.to_s == "a")
            if ( !url.nil? && !name.nil? )
                Lists.new.add(url, name)
            end 
        else
            out = Reader.new(id).info
            out.each do |id|
                page = MetaInspector.new(id[1])
                if page.meta_tags["property"]["og:image"].is_a?(Array)
                    img = page.meta_tags["property"]["og:image"].shift
                elsif page.meta_tags["property"]["og:image"].is_a?(String)
                    img = page.meta_tags["property"]["og:image"]
                end
                 event.send_embed("") do |embed|
                    embed.title       = id[0]
                    embed.url         = id[1]
                    embed.description = id[2].gsub(/<\/?[^>]*>/, "")
                    embed.footer = Discordrb::Webhooks::EmbedFooter.new(icon_url: "https://cdn.discordapp.com/embed/avatars/0.png")
                    embed.image = Discordrb::Webhooks::EmbedImage.new(url: img)
                end
            end
        end
    nil
    end
  end
end
