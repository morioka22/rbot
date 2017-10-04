module Bot
    module DiscordCommands
        module MapsCommands
            extend Discordrb::Commands::CommandContainer

            MAPS_API = 'http://maps.googleapis.com/maps/api/staticmap?format=png&size=640x480&center='

            command(:maps, usage: 'maps <始点> <終点>', description: 'Googleマップを表示', min_args: 2) do |event, startp, endp|
                maps_url = "#{MAPS_API}#{startp}|#{endp}&markers=label:S|#{startp}&markers=label:G|#{endp}"
                data = Net::HTTP.get(URI.parse(URI.encode(maps_url)))

                # そのまま送信できない?ため、一旦保存
                File.open('map.png', 'wb') do |f|
                    f.write(data)
                end
                # ファイルアップロード
                event.send_file(File.open('map.png'))
            end
        end
    end
end