module Bot
    module DiscordCommands
        module GameCommands
            extend Discordrb::Commands::CommandContainer

            require 'nokogiri'
            require 'capybara/poltergeist'

            STEAM_SEARCH_URL = 'https://steamcommunity.com/search/users/#text='
            PROFILE_REGEXP = /https?:\/\/steamcommunity.com\/profiles\//

            command(:osu, usage: 'osu <ユーザー名>', description: 'osu!のユーザー情報を表示') do |event, id|

                # osu!のユーザー情報取得
                apiurl  = CONFIG[:osu][:apiurl]
                apikey  = CONFIG[:osu][:apikey]
                json    = get_json("#{apiurl}?k=#{apikey}&u=#{id}&type=string")[0]

                rank = "**SS** : #{json["count_rank_ss"]} / **S** : #{json["count_rank_s"]} / **A** : #{json["count_rank_a"]}"
                country_rank = "##{json["pp_country_rank"].with_comma}"

                event.channel.send_embed do |embed|
                    embed.author = Discordrb::Webhooks::EmbedAuthor.new(
                        name:     'osu! Profile',
                        url:      "https://osu.ppy.sh/u/#{json["user_id"]}",
                        icon_url: 'https://i.ppy.sh/3ae9b08499c5b07e2c189aadc419aba4281211ce/687474703a2f2f772e7070792e73682f632f63392f4c6f676f2e706e67'
                    )
                    embed.footer = Discordrb::Webhooks::EmbedFooter.new(
                        text:     "#{json["country"]} (#{country_rank})",
                        icon_url: "#{CONFIG[:flag][:url]}#{json["country"].downcase}.png"
                    )
                    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
                        url: "https://a.ppy.sh/#{json["user_id"]}"
                    )
                    embed.color = CONFIG[:osu][:color]

                    # フィールド

                    embed.add_field(
                        name: 'Name',
                        value: json["username"],
                        inline: true
                    )
                    embed.add_field(
                        name: 'ID',
                        value: json["user_id"],
                        inline: true
                    )
                    embed.add_field(
                        name: 'Lv',
                        value: json["level"].to_i.to_s,
                        inline: true
                    )
                    embed.add_field(
                        name: 'PP',
                        value: json["pp_raw"].to_i.round.to_s.with_comma+"pp",
                        inline: true
                    )
                    embed.add_field(
                        name: 'Performance',
                        value: '#'+json["pp_rank"].with_comma,
                        inline: true
                    )
                    embed.add_field(
                        name: 'Ranked Score',
                        value: json["ranked_score"].with_comma,
                        inline: true
                    )
                    embed.add_field(
                        name: 'Hit Accuracy',
                        value: json["accuracy"].to_f.round(2).to_s+"%",
                        inline: true
                    )
                    embed.add_field(
                        name: 'Play Count',
                        value: json["playcount"].with_comma,
                        inline: true
                    )
                    embed.add_field(
                        name: 'Rank',
                        value: rank
                    )
                end
            end

            command(:steam, usage: 'steam <ユーザー名>', description: 'Steamのユーザー情報を表示') do |event, query|

                # Capybara/Poltergistの設定
                Capybara.register_driver :poltergeist do |app|
                    Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 100 })
                end

                # ページ取得
                session = Capybara::Session.new(:poltergeist)
                session.visit(STEAM_SEARCH_URL + query)

                # パース
                doc = Nokogiri::HTML(session.html)
                url = doc.css('.searchPersonaName')[0].attribute('href').to_s

                apikey = CONFIG[:steam][:apikey]
                id = nil

                # Steam IDの取得
                if url.match(PROFILE_REGEXP)
                    # プロフィールページの場合
                    id = url.match(/\d+/)[0]
                else
                    # カスタムURLの場合
                    vanityid = url.match(/id\/(.*)$/)[1]
                    vanitapi = "#{CONFIG[:steam][:vanitapi]}#{apikey}&vanityurl=#{vanityid}"
                    json = get_json(vanitapi)
                    id = json["response"]["steamid"]
                end

                playerapi = "#{CONFIG[:steam][:playerapi]}#{apikey}&steamids=#{id}"
                json = get_json(playerapi)["response"]["players"][0]
                
                event.channel.send_embed do |embed|
                    embed.author = Discordrb::Webhooks::EmbedAuthor.new(
                        name:     'Steam Profile',
                        url:      json["profileurl"],
                        icon_url: "http://cache.filehippo.com/img/ex/1901__Steam_icon.png"
                    )

                    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
                        url: json["avatarfull"]
                    )

                    embed.color = CONFIG[:steam][:color]

                    # ユーザー名
                    embed.add_field(
                        name: 'Name',
                        value: json["personaname"],
                        inline: true
                    )

                    # Steam ID
                    embed.add_field(
                        name: 'Steam ID',
                        value: json["steamid"],
                        inline: true
                    )

                    # オンライン/オフラインの表示
                    state = "Online"

                    if json["personastate"] == 0
                        state = "Offline"
                    end

                    embed.add_field(
                        name: 'Status',
                        value: state,
                        inline: true
                    )

                    # ここから表示/非表示が分かれる

                    # 国
                    if json.include?("loccountrycode")
                        embed.add_field(
                            name: 'Country',
                            value: json["loccountrycode"],
                            inline: true
                        )
                    end

                    if state == "Offline"
                        # フッター
                        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
                            text:     "Last Online",
                            icon_url: "http://www.iconsdb.com/icons/preview/gray/account-login-xxl.png"
                        )

                        # タイムスタンプ
                        last_online = Time.at(json["lastlogoff"])
                        embed.timestamp = last_online
                    end
                end
            end

            command(:test) do |event|
                server = event.server
                server.default_channel.send_message("#{event.user.mention}, Welcome to #{server.name}")
            end
        end
    end
end