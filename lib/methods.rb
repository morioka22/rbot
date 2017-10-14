require 'net/http'
require 'uri'
require 'json'
require 'time'

def get_json(location, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0
    uri = URI.parse(location)
    begin
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
            http.open_timeout = 5
            http.read_timeout = 10
            http.get(uri.request_uri)
        end
        case response
        when Net::HTTPSuccess
            json = response.body
            JSON.parse(json)
        when Net::HTTPRedirection
            location = response['location']
            warn "redirected to #{location}"
            get_json(location, limit - 1)
        else
            puts [uri.to_s, response.value].join(" : ")
            # handle error
        end
    rescue => e
        puts [uri.to_s, e.class, e].join(" : ")
        # handle error
    end
end

def post_json(location, json)
    uri = URI.parse(location)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    req.body = json
    return https.request(req)
end

# 正規表現でマッチした曜日を3文字の英語に変換
def match_to_wday(str)
    str.downcase!
    if str =~ /^今日|^today/
        return Time.now.strftime("%a").downcase
    end
    i = %w(^日|^sun ^月|^mon ^火|^tue ^水|^wed ^木|^thu ^金|^fri ^土|^sat).index{|r| str =~ /#{r}/}
    return %w(sun mon tue wed thu fri sat)[i] if i
end