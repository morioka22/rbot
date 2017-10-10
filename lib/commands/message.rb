module Bot
    module DiscordCommands
        module MessageCommands
            extend Discordrb::Commands::CommandContainer

            # 絵文字一覧表示
            command(:emoji, usage: 'emoji', description: '絵文字の一覧を表示') do |event|
                # 絵文字の取得(ハッシュ)
                emojis = event.server.emoji
                # ハッシュから値を取り出して配列にする
                e_ary = emojis.values
                # 配列を結合してスペースで区切って出力
                event.respond "#{e_ary.join(" ")}"
            end

            # メッセージ削除
            command(:del, usage: 'del <件数>', description: 'メッセージの削除', min_args: 1) do |event, n|
                next if (n.to_i > 99)
                event.channel.prune(n.to_i + 1, false)
                nil
            end
        end
    end
end