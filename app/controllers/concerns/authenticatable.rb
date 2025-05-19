module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JwtService.decode(token)

    if decoded
      @current_user = User.find_by(id: decoded['user_id'])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  rescue StandardError
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end