module Bot
    module DiscordEvents
        module MemberEvent
            extend Discordrb::EventContainer
            
            # メンバー参加時
            member_join do |event|
                event.server.default_channel.send_embed do |embed|
                    embed.title = "Member Joined"
                    embed.color = 14103594
                    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
                        url: event.user.avatar_url
                    )

                    embed.add_field(
                        name: event.user.name,
                        value: "＿人人人人人人人人人人人人人人＿\n＞ㅤㅤゆっくりしていってね！ㅤ＜\n￣Ｙ^Ｙ^Ｙ^Ｙ^Ｙ^Ｙ^Ｙ^Ｙ^Ｙ^Ｙ￣"
                    )
                end
            end

            # メンバー退出時
            member_leave do |event|
                event.server.default_channel.send_embed do |embed|
                    embed.title = "Member Left"
                    embed.color = 14103594
                    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
                        url: event.user.avatar_url
                    )

                    embed.add_field(
                        name: event.user.name,
                        value: "Bye Bye..."
                    )
                end
            end
        end
    end
end