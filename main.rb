ENV["SSL_CERT_FILE"] = 'E:/program/lib/cacert.pem'

require 'discordrb'
require 'yaml'
require_relative './lib/classes.rb'
require_relative './lib/methods.rb'

CONFIG = YAML.load_file('./config.yml')

module Bot
    BOT = Discordrb::Commands::CommandBot.new(
        token:     CONFIG[:bot][:token],
        client_id: CONFIG[:bot][:id],
        prefix:    CONFIG[:bot][:prefix]
    )

    # コマンドの読み込み
    module DiscordCommands; end
    Dir['lib/commands/*.rb'].each { |mod| load mod }
    DiscordCommands.constants.each do |mod|
        BOT.include! DiscordCommands.const_get mod
    end

    # イベント処理の読み込み
    module DiscordEvents; end
    Dir['lib/events/*.rb'].each { |mod| load mod }
    DiscordEvents.constants.each do |mod|
        BOT.include! DiscordEvents.const_get mod
    end

    BOT.run
end

bot.run
