class User < ApplicationRecord
    before_save { self.email = email.downcase }

    # name
    validates :name, presence: true, length: { maximum: 50 }

    # email
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true

    # password
    has_secure_password
    
    # has_secure_password only check for empty password not blank password so we need to add presence: true
    validates :password, length: { minimum: 6 }, presence: true 
end
