$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pg_flash_json'
require 'active_record'
require 'support/test_database_setup'
RSpec::Expectations.configuration.warn_about_potential_false_positives = false
