class String
    def with_comma
        self.gsub(/(\d)(?=\d{3}+$)/) { $1 + ',' }
    end

    # jsonpをjsonに変換
    def to_json
        self.match(/.*callback\((.*)\)/)[1]
    end

    # 英語3文字の曜日を日本語1文字に変換
    def to_jpn_wday
        i = %w(sun mon tue wed thu fri sat).index{|w| w == self}
        self.replace(%w(日 月 火 水 木 金 土)[i])
    end
end