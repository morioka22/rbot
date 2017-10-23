module Bot
    module DiscordCommands
        module MusicCommands
            extend Discordrb::Commands::CommandContainer

            command(:connect) do |event|
                if channel = event.user.voice_channel
                    BOT.voice_connect(channel)
                    nil
                else
                    event.respond 'ボイスチャンネルに参加してください'
                end
            end

            command(:disconnect) do |event|
                # コマンドを実行したサーバーのIDが入っているかチェック
                if event.bot.voices.has_key?(event.server.id)
                    event.voice.destroy
                    nil
                else
                    event.respond 'ボイスチャンネルに接続されていません'
                end
            end

            command(:pause) do |event|
                event.voice.pause
                event.respond '一時停止'
            end

            command(:stop) do |event|
                event.voice.stop_playing
                event.respond '再生停止'
            end

            command(:skip) do |event, sec|
                event.voice.skip(sec.to_f)
                nil
            end
        end
    end
end