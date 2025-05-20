module SidekiqAuth
  class Web
    def self.use!(username: ENV["SIDEKIQ_USERNAME"], password: ENV["SIDEKIQ_PASSWORD"])
      Sidekiq::Web.use Rack::Auth::Basic, "Protected Area" do |user, pass|
        ActiveSupport::SecurityUtils.secure_compare(user, username) &
        ActiveSupport::SecurityUtils.secure_compare(pass, password)
      end
    end
  end
end