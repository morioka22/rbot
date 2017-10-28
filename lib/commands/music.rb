module Bot
    module DiscordCommands
        module MusicCommands
            extend Discordrb::Commands::CommandContainer

            command(:connect, usage: 'connect', description: 'ボイスチャンネルに接続') do |event|
                if channel = event.user.voice_channel
                    BOT.voice_connect(channel)
                    nil
                else
                    event.respond 'ボイスチャンネルに参加してください'
                end
            end

            command(:disconnect, usage: 'disconnect', description: 'ボイスチャンネルから切断') do |event|
                # コマンドを実行したサーバーのIDが入っているかチェック
                if event.bot.voices.has_key?(event.server.id)
                    event.voice.destroy
                    nil
                else
                    event.respond 'ボイスチャンネルに接続されていません'
                end
            end

            command(:pause, usage: 'pause', description: '一時停止') do |event|
                event.voice.pause
                event.respond '一時停止'
            end

            command(:stop, usage: 'stop', description: '再生停止') do |event|
                event.voice.stop_playing
                event.respond '再生停止'
            end

            command(:skip, usage: 'skip <秒数>', description: '音声を秒数分スキップ', min_args: 1) do |event, sec|
                event.voice.skip(sec.to_f)
                nil
            end

            command(:volume, usage: 'volume <数値>', description: '音量を設定(0~200)', min_args: 1) do |event, vol|
                next unless (0.0..2.0).include?(vol.to_f)
                event.voice.volume = vol.to_f
                nil
            end
        end
    end
end