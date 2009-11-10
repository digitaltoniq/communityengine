class ApplyFormclass ContactForm < SimpleForm
  subject "Companies And Me application"
  recipients "your.email@your.domain.com"
  sender{|c| %{"#{c.name}" <#{c.email}>} }

  attribute :name,      :validate => true
  attribute :email,     :validate => /[^@]+@[^\.]+\.[\w\.\-]+/
  attribute :file,      :attachment => true

  attribute :message
  attribute :nickname,  :captcha  => true
end