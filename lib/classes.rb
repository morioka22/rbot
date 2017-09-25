class String
    def with_comma
        self.gsub(/(\d)(?=\d{3}+$)/, '\\1,')
    end
end