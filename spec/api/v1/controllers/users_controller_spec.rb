require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'GET /api/v1/users/:id' do
    let!(:user) { create(:user, name: 'abc', email: 'abc@test.com', token: 'NICEULTRATOKENVALID') }
    let!(:auth_header) { { 'Authorization' => user.token } }
    let(:do_action) { get "/api/v1/users/#{user.id}", headers: auth_header }
    let!(:user_json) do
      {
        'id' => user.id,
        'name' => user.name,
        'email' => user.email }
    end

    context 'unauthenticated' do
      let!(:do_action) { get '/api/v1/users/1' }

      it 'return 401 when showing user' do
        expect(response).to have_http_status 401
      end
    end

    context 'authenticated' do
      before do
        do_action
      end

      it 'return 200' do
        expect(response).to have_http_status 200
      end

      it 'render user json' do
        expect(JSON.parse(response.body)).to eq user_json
      end
    end

    context 'me' do
      let!(:do_action) { get '/api/v1/me', headers: auth_header }

      it 'return 200' do
        expect(response).to have_http_status 200
      end

      it 'render user json' do
        expect(JSON.parse(response.body)).to eq user_json
      end
    end

    context 'other user' do
      let!(:do_action) { get '/api/v1/users/2', headers: auth_header }

      it 'return 404' do
        expect(response).to have_http_status 404
      end
    end
  end
end
