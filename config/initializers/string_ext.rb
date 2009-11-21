class String
  def strip_html
    @strip_html ||= self.gsub(%r{</?[^>]+?>}, '').strip
  end
end