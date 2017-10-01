module Bot
    module DiscordCommands
        module TranslateCommands
            extend Discordrb::Commands::CommandContainer

            require 'cgi'
            require 'nokogiri'
            require 'capybara/poltergeist'

            command(:translate, usage: 'translate <文字列>', description: '日本語に翻訳') do |event, query|
                query = CGI.escape(query)
                url = "https://translate.google.com/#auto/ja/#{query}"

                Capybara.register_driver :poltergeist do |app|
                    Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 100 })
                end

                session = Capybara::Session.new(:poltergeist)
                session.visit(url)

                doc = Nokogiri::HTML(session.html)
                result = doc.css('#result_box').text

                event.respond result
            end
        end
    end
end