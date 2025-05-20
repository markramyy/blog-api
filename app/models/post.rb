class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true

  scope :by_user, ->(user) { where(user: user) }

  def authored_by?(user)
    self.user_id == user.id
  end
end
