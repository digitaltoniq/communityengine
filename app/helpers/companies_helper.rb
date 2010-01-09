module CompaniesHelper

  # TODO: this isn't right
  def more_company_representative_comments_links(company, displayed_comments)
    html = ""
    if company.representative_comments.count > displayed_comments.size
      html = link_to :all_company_representative_comments.l, representative_comments_company_url(company), :class => "button1"
      html += "<br />"
    end
		html
  end

  def popular_companies
    Company.popular.limited(5)
  end

  def recent_companies
    Company.recent.limited(5)
  end
end
