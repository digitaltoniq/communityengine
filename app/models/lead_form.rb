class LeadForm < SimpleForm
  
  subject "Companies And Me lead"
  recipients AppConfig.support_email
  sender {|f| %{"#{f.name}" <#{f.email}>} }

  attribute :name,      :validate => true
  attribute :title
  attribute :company
  attribute :phone
  attribute :email,     :validate => /[^@]+@[^\.]+\.[\w\.\-]+/

  attribute :message
end