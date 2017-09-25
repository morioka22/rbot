module Bot
    module DiscordCommands
        module MemberCommands
            extend Discordrb::Commands::CommandContainer

            # 指定したメンバーの詳細情報表示
            command(:member, usage: 'member <メンション>', description: 'メンバーの詳細情報を表示') do |event, user|
                # ユーザーIDの数字部分のみ抽出
                id = user.slice(/\d+/)
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

            # メンバー一覧表示
            command(:members, usage: 'members', description: 'メンバーの一覧を表示') do |event|
                members = event.server.members
                m_ary = members.map {|member| "@#{member.name}"}
                event.channel.send_embed do |embed|
                    embed.add_field(name: '__Members__', value: "#{m_ary.join("\n")}")
                end
            end

            # 指定したメンバーのアバター画像表示
            command(:avatar, usage: 'avatar <メンション>', description: 'メンバーのアバター画像を表示') do |event, user|
                id = user.slice(/\d+/)
                member = event.server.member(id)
                # 出力
                event.respond member.avatar_url
            end

            # キック
            command(:kick, usage: 'kick <メンション>', description: 'メンバーをキック') do |event, user|
                id = user.slice(/\d+/)
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

            # 役職ごとのメンバーを一覧表示
            command(:roleMembers, usage: 'roleMembers', description: '役職ごとのメンバーを一覧表示') do |event|
                # 役職一覧を取得
                event.server.roles.each do |role|
                    # @everyoneはスキップする
                    next if role.name == "@everyone"
                    m_ary = role.members.map {|member| "@#{member.name}"}
                    # 埋め込みで役職ごとのメンバーを表示
                    event.channel.send_embed do |embed|
                        # 配列を改行文字で結合
                        embed.add_field(name: "__Members in #{role.name}__", value: "#{m_ary.join("\n")}")
                    end
                end
            end

            # 役職付加
            command(:setRole, usage: 'setRole <メンション> <役職>', description: 'メンバーに役職を付加') do |event, user, role|
                id = user.slice(/\d+/)
                member = event.server.member(id)
                role = event.server.roles.select {|r|r.name == role}[0]
                member.add_role(role)
                event.respond "Added!"
            end

            # 役職削除
            command(:delRole, usage: 'delRole <メンション> <役職>', description: 'メンバーから役職を削除') do |event, user, role|
                id = user.slice(/\d+/)
                member = event.server.member(id)
                role = event.server.roles.select {|r|r.name == role}[0]
                member.remove_role(role)
                event.respond "Deleted!"
            end
        end
    end
end