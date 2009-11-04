xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @rss_title
    xml.link @rss_url

    for post in @posts
      xml.item do
        xml.title post.title
        xml.description post.post
        xml.pubDate post.published_at.to_s(:rfc822)
        xml.link post_url(post)
        xml.guid post_url(post)
      end
    end
  end
end