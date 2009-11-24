class String
  def strip_html
    @strip_html ||= self.gsub(%r{</?[^>]+?>}, '').strip
  end

  def truncate_words(length = 30, end_string = '...')
    return if self.blank?
    words = self.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end
end