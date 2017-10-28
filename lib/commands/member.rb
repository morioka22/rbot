module Bot
    module DiscordCommands
        module MemberCommands
            extend Discordrb::Commands::CommandContainer

            # 指定したメンバーの詳細情報表示
            command(:info, usage: 'info <メンション>', description: 'メンバーの詳細情報を表示', min_args: 1) do |event, mention|
                # ユーザーIDの数字部分のみ抽出
                id = mention.slice(/\d+/)
                # メンバーオブジェクトの取得
                member = event.server.member(id)
                # 役職一覧を取得
                roles = member.roles.map{|role| role.name}
                # 埋め込みでメンバー情報を表示
                event.channel.send_embed do |embed|
                    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
                    embed.add_field(name: '__Name__', value: "#{member.name}")
                    embed.add_field(name: '__ID__', value: "#{member.id}")
                    embed.add_field(name: '__Roles__', value: "#{roles.join(" ")}")
                end
            end

            # 指定したメンバーのアバター画像表示
            command(:avatar, usage: 'avatar <メンション>', description: 'メンバーのアバター画像を表示', min_args: 1) do |event, mention|
                id = mention.slice(/\d+/)
                member = event.server.member(id)
                # 出力
                event.respond member.avatar_url
            end

            # コマンドを打ったユーザー or 指定したメンバー のサーバー参加日を表示
            command(:joinedAt, usage: 'joinedAt <メンション>', description: 'メンバーのサーバー参加日を表示', min_args: 0) do |event, mention|
                if mention.nil?
                    date = event.user.joined_at.strftime("%Y/%m/%d")
                    event.respond("あなたの参加日: #{date}")
                else
                    id = mention.slice(/\d+/)
                    member = event.server.member(id)
                    date = member.joined_at.strftime("%Y/%m/%d")
                    event.respond("メンションされたメンバーの参加日: #{date}")
                end
            end

            # キック
            command(:kick, usage: 'kick <メンション>', description: 'メンバーをキック', min_args: 1) do |event, mention|
                id = mention.slice(/\d+/)
                name = event.server.member(id).name
                event.server.kick(id)
                event.respond "**#{name}** Kicked."
            end

            # ========== 役職系コマンド ==========

            # 役職一覧表示
            command(:roles, usage: 'roles', description: '役職の一覧を表示') do |event|
                # 役職一覧を取得
                roles = event.server.roles.map {|role| role.name}
                # 埋め込みで役職を表示
                event.channel.send_embed do |embed|
                    embed.add_field(name: '__Roles__', value: "#{roles.join("\n")}")
                end
            end

            # 役職のメンバー一覧表示
            command(:members, usage: 'members <役職名>', description: "指定した役職のメンバーを一覧表示", min_args: 1) do |event, rolename|
                # 引数と役職名が一致するものを抜き出す
                role = event.server.roles.find {|role| role.name == rolename}
                unless role.nil?
                    members_name = role.members.map {|member| "@#{member.name}"}
                    event.channel.send_embed do |embed|
                        embed.add_field(name: "__Members in #{role.name}__", value: "#{members_name.join("\n")}")
                        embed.add_field(name: '__Total__', value: "#{members_name.size}")
                    end
                else
                    event.respond '一致する役職がありません'
                    break
                end
            end

            # 役職付加
            command(:setRole, usage: 'setRole <メンション> <役職>', description: 'メンバーに役職を付加', min_args: 2) do |event, mention, role|
                id = mention.slice(/\d+/)
                member = event.server.member(id)
                role = event.server.roles.select {|r|r.name == role}[0]
                member.add_role(role)
                event.respond "Added!"
            end

            # 役職削除
            command(:delRole, usage: 'delRole <メンション> <役職>', description: 'メンバーから役職を削除', min_args: 2) do |event, mention, role|
                id = mention.slice(/\d+/)
                member = event.server.member(id)
                role = event.server.roles.select {|r|r.name == role}[0]
                member.remove_role(role)
                event.respond "Deleted!"
            end
        end
    end
end