module Bot
    module DiscordCommands
        module ShortenCommands
            extend Discordrb::Commands::CommandContainer

            require 'json'

            SHORTEN_URL = 'https://www.googleapis.com/urlshortener/v1/url?key='

            command(:shorten, usage: 'shorten <URL(スキームなし)>', description: '短縮URLを生成', min_args: 1) do |event, url|
                body = {"longUrl" => url}.to_json
                res = post_json(SHORTEN_URL + CONFIG[:google][:apikey], body)
                json = JSON.parse(res.body)
                event.respond json["id"]
            end
        end
    end
end