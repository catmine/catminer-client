require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CatminerClient
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    #config.autoload_paths << Rails.root.join('lib/models')

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec,
        :view_specs    => false,
        :request_specs => false,
        :routing_specs => false,
        :fixtures => false,
        :mailer_specs => false,
        :controller_specs => false,
        :helper_specs => false
    end

    config.after_initialize do
      begin
        ActiveRecord::Migration.check_pending!
        rig = Rig.default
        rig.start_mining
      rescue ActiveRecord::PendingMigrationError
      end
    end
  end
end
