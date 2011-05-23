# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Rriki2_session',
  :secret      => '217df790d2bb7db0f8b7ee952855ca4ba3203b0daf27bc608cc098797f4fed072881da3dc266b17ea63784ccc05bb3b985c7c0b5b5d8745bdd36c754ce239d46'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
