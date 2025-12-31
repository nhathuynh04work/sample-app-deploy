require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

    # clear the mail array because the `deliveries` array is global 
    # and would render the tests after the first one incorrect
    def setup
        ActionMailer::Base.deliveries.clear
    end

    test "invalid signup information with account activation" do
        get signup_path
        assert_no_difference "User.count" do
            post users_path, params: { user: { name: "",
                                                email: "user@invalid",
                                                password: "foo",
                                                password_confirmation: "bar" } }
        end

        assert_template "users/new"
        assert_select "div#error_explanation"
        assert_select "div.field_with_errors"
    end

    test "valid signup information" do
        get signup_path

        # ensure after signing up, a new, unactivated user is created
        assert_difference "User.count", 1 do
            post users_path, params: { user: { name: "Example",
                                                email: "user@example.com",
                                                password: "foobar",
                                                password_confirmation: "foobar" } }
        end

        assert_equal 1, ActionMailer::Base.deliveries.size 
        
        # use `assigns` to access the @user created in the UsersController
        user = assigns(:user)
        assert_not user.activated?

        # try logging in before activation
        log_in_as(user)
        assert_not is_logged_in?

        # invalid activation token
        get edit_account_activation_path("invalid", email: user.email)
        assert_not is_logged_in?

        # valid token, wrong email
        get edit_account_activation_path(user.activation_token, email: "invalid email")
        assert_not is_logged_in?

        # valid activation token
        get edit_account_activation_path(user.activation_token, email: user.email)
        assert user.reload.activated?
        follow_redirect!
        assert_template "users/show"
        assert is_logged_in?
    end
end
