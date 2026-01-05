class ApplicationController < ActionController::Base
    # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
    allow_browser versions: :modern

    # Changes to the importmap will invalidate the etag for HTML responses
    stale_when_importmap_changes

    # Make SessionsHelper available to all controllers
    include SessionsHelper

    private
        def logged_in_user
            unless logged_in?
                flash[:danger] = "Please log in."
                store_location
                redirect_to login_url
            end
        end
end
