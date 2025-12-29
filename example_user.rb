class User
    attr_accessor :first, :last, :email

    def initialize(attributes = {})
        @first = attributes[:first]
        @last = attributes[:last]
        @email = attributes[:email]
    end

    def full_name
        "#{@first} #{@last}"
    end

    def alphabetical_name
        "#{@last}, #{@first}"
    end

    def formatted_email
        "#{full_name} <#{@email}>"
    end
end
