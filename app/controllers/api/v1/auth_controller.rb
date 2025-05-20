module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [:signup, :login]

      def signup
        user = User.new(user_params)

        if user.save
          token = user.generate_auth_token
          render json: { user: user.as_json(except: :password_digest), token: token }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = user.generate_auth_token
          render json: { user: user.as_json(except: :password_digest), token: token }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :image)
      end
    end
  end
end