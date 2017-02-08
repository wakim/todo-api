require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :request do
  describe '#authenticate_user' do
    let!(:user) { create(:user) }

    context 'with invalid email' do
      let!(:params) { { email: 'lol@gmail.com', password: '123' } }
      let!(:do_action) { post '/api/v1/sessions/authenticate', params: params }

      it 'return 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with invalid password' do
      let!(:params) { { email: user.email, password: 'secret2' } }
      let!(:do_action) { post '/api/v1/sessions/authenticate', params: params }

      it 'return 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with valid email and password' do
      let!(:params) { { email: user.email, password: 'secret' } }
      let!(:do_action) { post '/api/v1/sessions/authenticate', params: params }

      it 'return 200' do
        expect(response).to have_http_status :ok
      end

      it 'render token' do
        expect(response.body).to eq '{"auth_token":"abc"}'
      end
    end
  end

  describe '#create' do
    let!(:user) { create(:user) }

    context 'with missing params' do
      let!(:params) { {} }
      let!(:do_action) { post '/api/v1/sessions/', params: params }

      it 'return 422' do
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'with empty email' do
      let!(:params) { { email: '', password: 'abc' } }
      let!(:do_action) { post '/api/v1/sessions/', params: params }

      it 'return 422' do
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'with empty password' do
      let!(:params) { { email: 'b@a.com', password: '' } }
      let!(:do_action) { post '/api/v1/sessions/', params: params }

      it 'return 422' do
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'with valid params' do
      let!(:params) { { email: 'b@a.com', password: 'lol' } }
      let!(:do_action) { post '/api/v1/sessions/', params: params }

      it 'return 200' do
        expect(response).to have_http_status :ok
      end

      it 'render token' do
        expect(response.body).to eq "{\"auth_token\":\"#{User.last.token}\"}"
      end
    end
  end
end
