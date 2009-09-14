module RepresentativesHelper

  def representative_path(rep)
    company_representative_path(rep.company, rep)
  end
end
