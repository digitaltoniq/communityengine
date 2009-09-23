module RepresentativesHelper

  def representative_path(rep, params = {})
    company_representative_path(rep.company, rep, params)
  end
end
