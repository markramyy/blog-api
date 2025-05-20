module AuthHelpers
    def generate_token(user)
        payload = { user_id: user.id }
        JWT.encode(payload, Rails.application.credentials.secret_key_base)
    end

    def json_response
        JSON.parse(response.body)
    end
end

RSpec.configure do |config|
    config.include AuthHelpers, type: :controller
end
