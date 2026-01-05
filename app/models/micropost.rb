class Micropost < ApplicationRecord
    # this line of code automatically add the following validation: validates :user, presence: true
    #
    # we might wonder: Why would we have "validates :user, presence: true" and "validates user_id, presence: true"
    # all in the same model?
    #
    # => in fact, we only need the `belongs_to` line for everything to be correct in newer version of Rails. 
    #    The only reason the author includes the user_id validation is because he wants to make sure that 
    #    people who use older version of Rails (even him in this tutorial) can still pass the test 
    #    where we set the user_id to nil and assert_not post.valid?
    #
    #    the reason is that in older version of Rails, when we set micropost.user = user1, Rails automatically set
    #    user_id = user1.id. However, if we set user_id = nil, user would still be there. If we don't validate the
    #    presence of user_id, the validation would check because the user is still there and the test would fail
    #
    #    the author also says that the test would still pass even if we don't include the user_id validation but 
    #    only if we use the idiomatically incorrect code. The explanation is that the idiomatically incorrect code
    #    (Micropost.new) only sets the user_id and therefore the validation would not check and the test would pass
    #    because user is still nil
    belongs_to :user

    has_one_attached :image

    default_scope -> { order(created_at: :desc) }

    validates :user_id, presence: true # we keep this for backward compatibility
    validates :content, presence: true, length: { maximum: 140 }
end
