class SessionsController < ApplicationController
    def new
    end

    def create
        user = User.find_by(email: params[:session][:email].downcase)

        if user && user.authenticate(params[:session][:password])
            # Log the user in and redirect to profile page
        else
            flash[:danger] = "Invalid email/password"
            render "new", status: :unprocessable_entity
        end
    end

    def destroy

    end
end
