require_relative 'news'
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

out = Reader.new("1").info
list = ""
out.each do |m|
    embeds["title"]            = m[0].to_s
    embeds["url"]              = m[1].to_s
    embeds["description"]      = m[2].to_s
end
h["embed"]  =  embeds



puts h.to_json
