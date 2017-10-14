module Bot
    module DiscordCommands
        module WeatherCommands
            extend Discordrb::Commands::CommandContainer
            JPN_WEATHER_FORECAST = 'http://www.drk7.jp/weather/json/'

            command(:weather, usage: 'weather <都道府県名> <地名>', description: '天気情報を表示', min_args: 1) do |event, pref_name, area_name|
                list = JSON.load(open('weather.json'))

                # リストから検索してIDを抽出
                pref = list.find {|pref| pref["name"] == pref_name}
                id = pref["id"]

                # jsonpを取得
                uri = URI.parse(JPN_WEATHER_FORECAST + "#{id}.js")
                jsonp = Net::HTTP.get(uri)
                # JSONP -> JSONに変換
                json = JSON.load(jsonp.to_json)

                weather = nil

                unless area_name.nil?
                    # エリアが指定されている時
                    unless json["pref"]["area"]["#{area_name}"].nil?
                        weather = json["pref"]["area"]["#{area_name}"]["info"][0]
                    else
                        event.respond 'エリアが見つかりません'
                    end
                else
                    # エリアが指定されていない時
                    # weather.json(area)の最初の項目を指定 or なし
                    unless pref["area"][0].nil?
                        area_name = pref["area"][0]
                        weather = json["pref"]["area"]["#{area_name}"]["info"][0]
                    else
                        weather = json["pref"]["area"]["info"][0]
                    end
                end

                # 値の抽出
                pref       = json["pref"]["id"]
                telop      = weather["weather"]
                maxtemp    = weather["temperature"]["range"][0]["content"]
                mintemp    = weather["temperature"]["range"][1]["content"]
                img        = weather["img"]
                fallchance = Array.new

                # 降水確率を配列に追加
                weather["rainfallchance"]["period"].each do |chance|
                    fallchance << chance["content"]
                end

                event.channel.send_embed do |embed|
                    embed.title = "#{pref}の天気情報"
                    embed.description = telop

                    # 埋め込みカラー
                    embed.color = case telop
                    when /雪/
                        CONFIG[:weather][:snow]
                    when /雨/
                        CONFIG[:weather][:rain]
                    when /晴れ/
                        CONFIG[:weather][:sunny]
                    when /くもり/
                        CONFIG[:weather][:cloudy]
                    else
                        CONFIG[:weather][:cloudy]
                    end

                    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
                        url: img
                    )

                    embed.add_field(
                        name: '最高気温',
                        value: maxtemp + '℃',
                        inline: true
                    )

                    embed.add_field(
                        name: '最低気温',
                        value: mintemp + '℃',
                        inline: true
                    )

                    embed.add_field(
                        name: '午前の降水確率',
                        value: "0時~6時: #{fallchance[0]}%\n6時~12時: #{fallchance[1]}%",
                        inline: true
                    )

                    embed.add_field(
                        name: '午後の降水確率',
                        value: "12時~18時: #{fallchance[2]}%\n18時~24時: #{fallchance[3]}%",
                        inline: true
                    )
                end
            end
        end
    end
end