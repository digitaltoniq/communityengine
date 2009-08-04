# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_candme_session',
  :secret      => '7asdf7asdfkasdfa9sd8asdf98asd0f987asd908f7g87sd6fg8s7df6g87dfs6g87dfs6g87dfs6g87dsf6g87fsd6g876sdfg876sdfg876dsf8g76dfs87g6dsf87'
}
# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
