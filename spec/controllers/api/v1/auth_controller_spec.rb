require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :controller do
  describe 'POST #signup' do
    let(:valid_params) do
      {
        user: {
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          image: 'https://example.com/image.jpg'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user and returns token' do
        expect {
          post :signup, params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['user']['email']).to eq('john@example.com')
        expect(json_response['token']).to be_present
        expect(json_response['user']['password_digest']).to be_nil
      end
    end

    context 'with invalid parameters' do
      it 'returns error for invalid email format' do
        post :signup, params: {
          user: valid_params[:user].merge(email: 'invalid-email')
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Email is invalid')
      end

      it 'returns error for short password' do
        post :signup, params: {
          user: valid_params[:user].merge(password: '12345')
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Password is too short (minimum is 6 characters)')
      end

      it 'returns error for missing required fields' do
        post :signup, params: {
          user: { email: 'test@example.com' }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Name can't be blank")
        expect(json_response['errors']).to include("Image can't be blank")
      end

      it 'returns error for duplicate email' do
        create(:user, email: 'john@example.com')

        post :signup, params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Email has already been taken')
      end
    end
  end

  describe 'POST #login' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns user data and token' do
        post :login, params: { email: user.email, password: 'password123' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['token']).to be_present
        expect(json_response['user']['password_digest']).to be_nil
      end
    end

    context 'with invalid credentials' do
      it 'returns error for wrong password' do
        post :login, params: { email: user.email, password: 'wrong_password' }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns error for non-existent email' do
        post :login, params: { email: 'nonexistent@example.com', password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns error for missing credentials' do
        post :login, params: {}

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end
  end
end