module CompaniesHelper

  # TODO: this isn't right
  def more_company_representative_comments_links(company, displayed_comments)
    html = ""
    if company.representative_comments.count > displayed_comments.size
      html = link_to "&raquo; " + :all_company_representative_comments.l, representative_comments_company_url(company)
      html += "<br />"
    end
    html += link_to "&raquo; " + :company_representative_comments_rss.l, representative_comments_company_url(company, :format => :rss)
		html
  end
end
