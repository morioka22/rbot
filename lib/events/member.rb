module Bot
    module DiscordCommands
        module MemberEvent
            extend Discordrb::EventContainer
            
            # メンバー参加時
            member_join do |event|
                server = event.server
                server.default_channel.send_message("#{event.user.mention}, Welcome to #{server.name}")
            end

            # メンバー退出時
            member_leave do |event|
                server.default_channel.send_message("ByeBye...")
            end
        end
    end
end