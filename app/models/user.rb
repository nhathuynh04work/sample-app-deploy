class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token

    before_save :email_downcase
    before_create :create_activation_digest

    # name
    validates :name, presence: true, length: { maximum: 50 }

    # email
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true

    # password
    has_secure_password

    # has_secure_password only check for empty (nil) password not blank password so we need to add presence: true
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
