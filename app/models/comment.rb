class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :content, presence: true

  def authored_by?(user)
    self.user_id == user.id
  end
end
