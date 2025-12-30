class UsersController < ApplicationController
    before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
    before_action :correct_user, only: [:edit, :update]
    before_action :admin_user, only: [:destroy]

    def index
        @users = User.paginate(page: params[:page])
    end

    def new
        @user = User.new
    end

    def show
        @user = User.find(params[:id])
    end

    def create
        @user = User.new(user_params)

        if @user.save
            log_in @user
            flash[:success] = "Welcome to the Sample App!"
            redirect_to @user # Rails infers that we want to write: redirect_to user_url(@user)
        else
            render "new", status: :unprocessable_entity
        end
    end

    def edit
        # @user is retrieved by correct_user
    end

    def update
        if @user.update(user_params)
            flash[:success] = "Profile updated"
            redirect_to @user
        else
            render "edit", status: :unprocessable_entity
        end
    end

    def destroy
        User.find(params[:id]).destroy
        flash[:success] = "User deleted"
        redirect_to users_url
    end

    # Private
    private
    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def logged_in_user
        unless logged_in?
            flash[:danger] = "Please log in."
            store_location
            redirect_to login_url
        end
    end

    def correct_user
        # This also sets the @user in the action it runs before
        @user = User.find(params[:id])
        redirect_to root_url unless @user == current_user
    end

    def admin_user
        redirect_to(root_url) unless current_user.admin?
    end
end
