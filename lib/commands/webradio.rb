module Bot
    module DiscordCommands
        module RadioCommands
            extend Discordrb::Commands::CommandContainer

            require 'nokogiri'
            require 'open-uri'
            
            ONSEN_TOP          = 'http://www.onsen.ag'
            ONSEN_SCHEDULE_API = 'http://www.onsen.ag/api/shownMovie/shownMovie.json'
            ONSEN_INFO_API     = 'http://www.onsen.ag/data/api/getMovieInfo/'

            command(:onsenList, usage: 'onsenList <曜日>', description: '音泉の番組リストを表示') do |event, wday|
                # 曜日を判定
                if wday
                    wday = match_to_wday(wday)
                else
                    # wdayが空の場合はtodayを設定
                    wday = match_to_wday('today')
                end
                # 判定後に空の場合は抜ける
                next unless wday

                # 指定した曜日のリストを取得
                doc = Nokogiri::HTML(open(ONSEN_TOP))
                list = doc.css('.listWrap .clr li')
                result = list.select {|item| item.get_attribute('data-week') == wday}

                event.channel.send_embed do |embed|
                    embed.color = CONFIG[:onsen][:color]
                    embed.timestamp = Time.now

                    embed.author = Discordrb::Webhooks::EmbedAuthor.new(
                        name: "音泉 番組表(#{wday.to_jpn_wday})",
                        url: "http://www.onsen.ag",
                        icon_url: "https://lh3.googleusercontent.com/Cr5L2jLfye8-FSFPzXEPA_2EQtGEed-4IwEOY-_4DMePG3zUwQD9O0ZwBpYYBrnx6R0l=w50"
                    )

                    result.each do |item|
                        id        = item.get_attribute('id')
                        title     = item.css('h4').text.gsub("　", "\s")
                        update    = item.get_attribute('data-update')
                        navigator = item.css('.navigator').text

                        embed.add_field(
                            name: "[#{id}] #{title}",
                            value: "更新日: #{update}\nパーソナリティ: #{navigator}"
                        )
                    end
                end
            end

            command(:onsenInfo, usage: 'onsenInfo <番組ID>', description: '音泉の番組情報を表示', min_args: 1) do |event, id|
                uri = URI.parse(ONSEN_INFO_API + id)
                json = JSON.load(Net::HTTP.get(uri).to_json)

                title       = json["title"].gsub("　", "\s")
                id          = json["url"]
                personality = json["personality"].split('/').map(&:strip!)
                thumbnail   = json["thumbnailPath"]
                schedule    = json["schedule"]
                update      = json["update"]
                count       = json["count"].to_i

                event.channel.send_embed do |embed|
                    embed.color = CONFIG[:onsen][:color]

                    embed.image = Discordrb::Webhooks::EmbedImage.new(
                        url: "#{ONSEN_TOP}#{thumbnail}"
                    )
                    embed.author = Discordrb::Webhooks::EmbedAuthor.new(
                        name: "音泉 番組詳細",
                        url: "http://www.onsen.ag/program/#{id}",
                        icon_url: "https://lh3.googleusercontent.com/Cr5L2jLfye8-FSFPzXEPA_2EQtGEed-4IwEOY-_4DMePG3zUwQD9O0ZwBpYYBrnx6R0l=w50"
                    )

                    embed.add_field(name: "番組名", value: title)
                    embed.add_field(name: "配信日時", value: schedule, inline: true)
                    embed.add_field(name: "最新配信日", value: update, inline: true)
                    embed.add_field(name: "配信回数", value: "#{count}回", inline: true)
                    embed.add_field(name: "パーソナリティ", value: personality.join("\n"))
                end
            end

            command(:onsenPlay, usage: 'onsenPlay <番組ID>', description: '音泉の番組を再生', min_args: 1) do |event, id|
                uri = URI.parse(ONSEN_INFO_API + id)
                json = JSON.load(Net::HTTP.get(uri).to_json)
                moviePath = json["moviePath"]["pc"]
                title = json["title"].gsub("　", "\s")

                BOT.voice_connect(event.user.voice_channel)
                event.respond "ダウンロード中..."
                File.open("./radio/#{title}.mp3", 'wb') do |saved_file|
                    open(moviePath, 'rb') do |read_file|
                        saved_file.write(read_file.read)
                    end
                end
                event.respond "#{title}を再生開始"
                event.voice.play_file("./radio/#{title}.mp3")
                event.respond "再生終了"
                event.voice.destroy
                nil
            end
        end
    end
end