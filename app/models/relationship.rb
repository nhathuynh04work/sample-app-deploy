class Relationship < ApplicationRecord
    belongs_to :follower, class_name: "User"
    belongs_to :followed, class_name: "User"

    # the following 2 lines are optional but actually needed in older Rails versions
    validates :follower_id, presence: true
    validates :followed_id, presence: true
end
