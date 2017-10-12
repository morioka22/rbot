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

                event.channel.send_embed do |embed|
                    embed.color = CONFIG[:google][:color]
                    embed.author = Discordrb::Webhooks::EmbedAuthor.new(
                        name:     'URL Shortener',
                        icon_url: 'https://lh3.googleusercontent.com/kroer1kpwSe3j-lIfPnE7Q3MVaCoJVF8atjdh0VtGDWCz2ulLejVsDh2k6a6VUgpUFQ8qRMHMEX7bsr2jTrLXhZR_ETbqILDf-qfkk0=h128'
                    )
                    embed.footer = Discordrb::Webhooks::EmbedFooter.new(
                        text:     "Created by #{event.author.name}",
                        icon_url: "#{event.author.avatar_url}"
                    )
                    embed.add_field(name: 'Original', value: "#{url}")
                    embed.add_field(name: 'Shortened', value: "#{json["id"]}")
                end
            end
        end
    end
end