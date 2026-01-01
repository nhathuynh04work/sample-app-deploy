class PasswordResetsController < ApplicationController
    before_action :get_user, only: [:edit, :update]
    before_action :valid_user, only: [:edit, :update]
    before_action :check_expiration, only: [:edit, :update]

    def new
    end

    def edit
        
    end

    def create
        @user = User.find_by(email: params[:password_reset][:email].downcase)

        if @user
            @user.create_reset_digest
            @user.send_password_reset_email

            flash[:info] = "Email sent with password reset instruction"
            redirect_to root_url
        else
            flash.now[:danger] = "Email address not found"
            render "new", status: :unprocessable_entity
        end
    end

    # Why we need to check the password empty case?
    # => Although we have `presence: true` provided by `has_secure_password` and by our own written rules,
    #    the empty password could still bypass these validation rules and cause problems
    #    1) Our written rules has `allow_nil: true` which allow empty password field to bypass all validation checks
    #    2) The `presence: true` of has_secure_password only runs on CREATION
    #
    #    And since we're updating user's password, we cannot allow it to be empty
    def update
        if params[:user][:password].empty?
            @user.errors.add(:password, :blank)
            render "edit", status: :unprocessable_entity
        elsif @user.update(user_params)
            # clear the reset_digest to avoid user using the back button to change password again
            @user.update_attribute(:reset_digest, nil)
            
            log_in @user
            flash[:success] = "Password has been reset"

            redirect_to @user
        else
            render "edit", status: :unprocessable_entity
        end
    end

    private
        def user_params
            params.require(:user).permit(:password, :password_confirmation)
        end

        def get_user
            @user = User.find_by(email: params[:email])
        end

        def valid_user
            unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
                redirect_to root_url
            end
        end

        def check_expiration
            if @user.password_reset_expired?
                flash[:danger] = "Password reset has expired"
                redirect_to new_password_reset_url
            end
        end
end
