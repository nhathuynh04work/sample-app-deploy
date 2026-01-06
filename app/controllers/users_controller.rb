class UsersController < ApplicationController
    before_action :logged_in_user, only: [:edit, :update, :index, :destroy, :following, :followers]
    before_action :correct_user, only: [:edit, :update]
    before_action :admin_user, only: [:destroy]

    def index
        @users = User.where(activated: true).paginate(page: params[:page])
    end

    def new
        @user = User.new
    end

    def show
        @user = User.find(params[:id])
        @microposts = @user.microposts.paginate(page: params[:page])
        redirect_to root_url and return false unless @user.activated?
    end

    def create
        @user = User.new(user_params)

        if @user.save
            @user.send_activation_email
            flash[:info] = "Please check your email to activate your account."
            redirect_to root_url

            # This is old but I keep it here for the note about Rails infer
            #redirect_to @user # Rails infers that we want to write: redirect_to user_url(@user)
        else
            render "new", status: :unprocessable_entity
        end
    end

    def edit
        # @user is retrieved by correct_user
    end

    # How does the action know not to update the password when we sent it an empty string?
    # => There are a few things to fully understand here
    # 1) When we run @user.update, Rails run something like this:
    #    def update(attributes)
    #       attributes.each do |key, value|
    #           setter_method = "#{key}="  
    #           self.send(setter_method, value) 
    #       end
    #       save
    #    end
    #
    # 2) For every real real attribute of a model, Rails automatically create a setter method
    #    For example: The User model will have `name=`, `email=`. 
    #    The setter method are simply the same as when you write user.name = "Nhat"
    #    
    #    When we add has_secure_password, it adds a setter method for the virtual attributes `password` that looks like:
    #    def password=(unencrypted_password)
    #        if unencrypted_password.nil? || unencrypted_password.empty?
    #            return
    #        end
    #
    #        self.password_digest = BCrypt::Password.create(unencrypted_password)
    #    end
    #    
    #    The special thing about this setter is that it will hash and set the `password_digest` field
    #    of the User object if the password field is not null
    #
    # 3) SQL Generation.
    #    When we save the data of a model instance to the database, 
    #    Rails will generate the SQl based on "dirty" fields.
    #    For example if our user variable has its name changed from "A" to "B" and their email kept the same
    #    The SQL code will only update the name column.
    #
    #    Because of this "laziness", when we send an empty or nil `password` field to the update action
    #    and it calls @user.update(), which leads to calling password= created by has_secure_password,
    #    which leads to our `password_digest` field not updated (not dirty) 
    #    and therefore SQL code generated does not update the password_digest column
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

    def following
        @title = "Following"
        @user = User.find(params[:id])
        @users = @user.following.paginate(page: params[:page])
        render 'show_follow'
    end

    def followers
        @title = "Followers"
        @user = User.find(params[:id])
        @users = @user.followers.paginate(page: params[:page])
        render 'show_follow'
    end

    # Private
    private
        def user_params
            params.require(:user).permit(:name, :email, :password, :password_confirmation)
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
