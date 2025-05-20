class PostDeletionWorker
    include Sidekiq::Worker

    def perform(post_id)
        post = Post.find_by(id: post_id)
        post&.destroy if post && post.created_at <= 24.hours.ago
    end
end