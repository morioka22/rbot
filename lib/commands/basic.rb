module Bot
    module DiscordCommands
        module BasicCommands
            extend Discordrb::Commands::CommandContainer

            require 'time'

            command(:time, usage: 'time <オプション>', description: '現在時刻を表示') do |event, option|
                now = DateTime.now
                dow = ['日', '月', '火', '水', '木', '金', '土']

                date = "#{now.year}年#{now.month}月#{now.day}日(#{dow[now.wday]})"
                time = "#{now.hour}時#{now.minute}分#{now.second}秒"

                # オプションのチェック
                if option == nil
                    event.respond "#{date}\n#{time}"
                else
                    if option == '-time'
                        event.respond time
                    else
                        if option == '-date'
                            event.respond date
                        end
                    end
                end
            end

            command(:shutdown, usage: 'shutdown', description: 'Botを終了') do |event|
                next unless event.author == '153106386585255936'
                exit(0)
                nil
            end
        end
    end
end