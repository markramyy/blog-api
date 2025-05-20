class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, presence: true
  validates :body, presence: true
  validate :has_at_least_one_tag

  scope :by_user, ->(user) { where(user: user) }

  after_create :schedule_deletion

  def authored_by?(user)
    self.user_id == user.id
  end

  def tag_list
    tags.map(&:name).join(', ')
  end

  def tag_list=(names)
    tag_names = names.split(',').map(&:strip)
    existing_tags = Tag.where(name: tag_names)

    missing_tag_names = tag_names - existing_tags.map(&:name)
    new_tags = missing_tag_names.map { |name| Tag.create!(name: name) }

    self.tags = existing_tags + new_tags
  end

  private

  def has_at_least_one_tag
    if tags.empty?
      errors.add(:tags, "must have at least one tag")
    end
  end

  def schedule_deletion
    PostDeletionWorker.perform_in(24.hours, id)
  end
end
