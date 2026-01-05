require "active_support/core_ext/integer/time"

Rails.application.configure do
    # Settings specified here will take precedence over those in config/application.rb.

    # Code is not reloaded between requests.
    config.enable_reloading = false

    # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
    config.eager_load = true

    # Full error reports are disabled.
    config.consider_all_requests_local = false

    # Turn on fragment caching in view templates.
    config.action_controller.perform_caching = true

    # Cache assets for far-future expiry since they are all digest stamped.
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

    # Enable serving of images, stylesheets, and JavaScripts from an asset server.
    # config.asset_host = "http://assets.example.com"

    # Store uploaded files on the local file system (see config/storage.yml for options).
    config.active_storage.service = :amazon

    # image processing
    config.active_storage.variant_processor = :mini_magick

    # Assume all access to the app is happening through a SSL-terminating reverse proxy.
    config.assume_ssl = true

    # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
    # config.force_ssl = true

    # Skip http-to-https redirect for the default health check endpoint.
    # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

    # Log to STDOUT with the current request id as a default log tag.
    config.log_tags = [ :request_id ]
    config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

    # Change to "debug" to log everything (including potentially personally-identifiable information!).
    config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

    # Prevent health checks from clogging up the logs.
    config.silence_healthcheck_path = "/up"

    # Don't log any deprecations.
    config.active_support.report_deprecations = false

    # Replace the default in-process memory cache store with a durable alternative.
    config.cache_store = :solid_cache_store

    # Replace the default in-process and non-durable queuing backend for Active Job.
    config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

    # 1. "Don't fail silently."
    # If SendGrid rejects the password or the email, your app will crash (500 error) 
    # so you know something is wrong, rather than pretending it worked.
    config.action_mailer.raise_delivery_errors = true

    # 2. "Use the Real World."
    # Tells Rails to use the Simple Mail Transfer Protocol (SMTP) standard
    # instead of just logging to a file or saving to an array (like in test).
    config.action_mailer.delivery_method = :smtp

    # 3. "Where do links go?"
    # When you write `edit_user_url(user)` inside an email, Rails doesn't know 
    # if it's running on localhost or on render.com. 
    # This line tells Rails: "If you make a link, put 'sample-app...onrender.com' in front."
    config.action_mailer.perform_caching = false
    host = ENV['RENDER_EXTERNAL_HOSTNAME'] || 'sample-app-deploy-3ty9.onrender.com'
    config.action_mailer.default_url_options = { host: host, protocol: "https" }

    # 4. The Connection Details
    config.action_mailer.smtp_settings = {
        address:        'smtp.sendgrid.net',    

        # For port, the default port for email service is 587 
        # but it's so popular that sometimes it causes slow connection
        # leading to timeout error (which we are currently encountered)
        # Therefore we switch to port 2525 as it is SendGrid's minor port designed to handle this issue
        port:           2525,                     
        domain:         host,                     # Identifying our app's domain to SendGrid
        user_name:      'apikey',                 # The standard SendGrid username
        password:       ENV['SENDGRID_API_KEY'],  # The Secret Key
        authentication: 'plain',                  # The method of sending the password
        enable_starttls_auto: true                # Encrypt the connection (SSL/TLS) so hackers can't read the email
    }

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation cannot be found).
    config.i18n.fallbacks = true

    # Do not dump schema after migrations.
    config.active_record.dump_schema_after_migration = false

    # Only use :id for inspections in production.
    config.active_record.attributes_for_inspect = [ :id ]

    # Enable DNS rebinding protection and other `Host` header attacks.
    # config.hosts = [
    #   "example.com",     # Allow requests from example.com
    #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
    # ]
    #
    # Skip DNS rebinding protection for the default health check endpoint.
    # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
