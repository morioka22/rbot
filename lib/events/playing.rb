module Bot
    module DiscordEvents
        module PlayingEvent
            extend Discordrb::EventContainer
            
            playing do |event|
                unless event.user.id == 153106386585255936
                    puts "#{event.user.name}のステータスが#{event.game}に変更されました"
                    nil
                end
            end
        end
    end
end