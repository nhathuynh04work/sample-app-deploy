class User < ApplicationRecord
    # relationships
    has_many :microposts, dependent: :destroy

    # virtual attributes
    attr_accessor :remember_token, :activation_token, :reset_token

    # callbacks
    before_save :email_downcase
    before_create :create_activation_digest

    # validations
    validates :name, presence: true, length: { maximum: 50 }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true

    # has_secure_password needs to be used with bcrypt gem and the model has a password_digest column
    # it adds the following:
    # 1) virtual attributes: password and password_confirmation
    # 2) before_save callback that hash the password and save it in password_digest
    # 3) `authenticate(string)` method that checks if the string matches the password_digest field
    # 4) validations: 
    #    + password: presence: true ONLY ON CREATION
    #    + password and password_confirmation matches only if password.present? 
    #    + password: maximum length of 72 bytes
    has_secure_password

    # this validation rules add to the rules already enforced by `has_secure_password` (HSC)
    # 1) Why is there `presence: true` here when HSC already has it? 
    #    => The presence check of HSC only happens on CREATION and it only checks for non-nil value, 
    #       meaning that "   " can still pass the check.
    #       Therefore, we add this here to make sure that when UPDATING the password, it must be a valid string
    #
    # 2) What the `allow_nil` does here?
    #    => `allow_nil: true` checks if the data is nil. If yes, then it would SKIP the other validation rules.
    #
    # 3) Does the `allow_nil: true` and `presence: true` clashes one another?
    #    => No. The `allow_nil` runs before `presence` therefore if the data is nil, the presence check is skipped
    #       and no error is raised. This is helpful for when the user is editing their profile in the profile edit page.
    #       When they leave the password field empty, the form would by default sent it as a nil field and hence
    #       allows user to have to reenter the password field when they just want to change the name or email (good UX)
    validates :password, length: { minimum: 6 }, presence: true, allow_nil: true

    # saves the user's hashed token for use in persistent session
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # returns true if a given token matches the digest
    def authenticated?(attribute, token)
        digest = self.send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # forgets a user
    def forget
        update_attribute(:remember_digest, nil)
    end

    # returns the hash digest of  the given string
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # returns a random token
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # activates an account
    def activate
        self.update_columns(activated: true, activated_at: Time.zone.now)
    end

    # send email with activation token
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # set the password reset attributes
    def create_reset_digest
        self.reset_token = User.new_token
        reset_digest = User.digest(reset_token)

        update_columns(reset_digest: reset_digest, reset_sent_at: Time.zone.now)
    end

    # send password reset email
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # return true if a password reset has expired
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    # returns microposts of a current user
    def feed
        Micropost.where("user_id = ?", id)

        # we can alternatively just write microposts (= self.microposts)
    end

    # private
    private
    def email_downcase
        self.email = email.downcase
    end

    def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
    end
end
