module CompaniesHelper

  # TODO: this isn't right
  def more_company_post_comments_links(commentable)
    html = link_to "&raquo; " + :all_comments.l, comments_company_conversations_url(commentable)
    html += "<br />"
		html += link_to "&raquo; " + :comments_rss.l, comments_company_conversations_url(commentable, :format => :rss)
		html
  end
end