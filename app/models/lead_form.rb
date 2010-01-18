class LeadForm < SimpleForm
  
  subject "Companiesandme company signup"
  recipients AppConfig.support_email
  sender {|f| %{"#{f.name}" <#{f.email}>} }

  attribute :name,      :validate => true
  attribute :title
  attribute :company
  attribute :website
  attribute :phone
  attribute :preference
  attribute :email,     :validate => /[^@]+@[^\.]+\.[\w\.\-]+/
  attribute :message
end
