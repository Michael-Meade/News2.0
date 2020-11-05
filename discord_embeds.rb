require_relative 'news'
require 'metainspector'
require 'discordrb'
h =  { 
    "content" => " **Bleeping Computer**",
        "embed" => {
                "title" => "",
                "description" => "",
                "url" => "",
                "color" => 7506394
            }
        }

embeds = h["embed"]
out = Reader.new(id).info
list = ""
out.each do |m|
    embeds["title"]            = m[0].to_s
    embeds["url"]              = m[1].to_s
    embeds["description"]      = m[2].to_s
end
h["embed"]  =  embeds

page = MetaInspector.new(h["embed"]["url"])
event.send_embed("") do |embed|
    embed.title       = h["embed"]["title"]
    embed.url         = h["embed"]["url"]
    embed.description = h["embed"]["description"].gsub(/<\/?[^>]*>/, "")
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "footer text", icon_url: "https://cdn.discordapp.com/embed/avatars/0.png")
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: page.meta_tags["property"]["og:image"].shift.to_s)
end
