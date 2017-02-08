require 'rails_helper'

RSpec.describe Api::V1::ItemsController, type: :request do
  let!(:user) { create(:user, name: 'abc', email: 'abc@test.com', token: 'NICEULTRATOKENVALID') }
  let!(:other_user) { create(:user, name: 'abc 2', email: 'abc_2@test.com') }
  let!(:auth_header) { { 'Authorization' => user.token } }

  %w(me user/:user_id).each do |endpoint|
    describe "GET /#{endpoint}/items/" do
      if endpoint == 'me'
        let(:do_action) { get '/api/v1/me/items', headers: auth_header }
      else
        let(:do_action) { get "/api/v1/users/#{user.id}/items", headers: auth_header }
      end

      context 'unauthenticated' do
        if endpoint == 'me'
          let!(:do_action) { get '/api/v1/me/items' }
        else
          let!(:do_action) { get '/api/v1/users/1/items' }
        end

        it 'return 401' do
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'authenticated' do
        context 'query other user items' do
          if endpoint != 'me'
            let!(:do_other_user_action) { get '/api/v1/users/2/items', headers: auth_header }

            it 'return 401' do
              expect(response).to have_http_status :unauthorized
            end
          end
        end

        context 'query all current user items' do
          let!(:item_1) { create(:item, user_id: user.id, name: 'item 1', description: 'desc 1') }
          let!(:item_2) { create(:item, user_id: user.id, name: 'item 2', description: 'desc 2', done: true) }

          let!(:items_json) do
            [{
              'id' => 1,
              'name' => 'item 1',
              'description' => 'desc 1',
              'user_id' => 1,
              'done' => false },
             {
               'id' => 2,
               'name' => 'item 2',
               'description' => 'desc 2',
               'user_id' => 1,
               'done' => true }]
          end

          before do
            do_action
          end

          it 'return 200' do
            expect(response).to have_http_status :ok
          end

          it 'render items json' do
            expect(JSON.parse(response.body)).to eq items_json
          end
        end

        context 'query first page of current user items' do
          let!(:item_1) { create(:item, user_id: user.id, name: 'item 1', description: 'desc 1') }
          let!(:item_2) { create(:item, user_id: user.id, name: 'item 2', description: 'desc 2', done: true) }

          let!(:params) { { page: 1, per: 1 } }

          if endpoint == 'me'
            let(:do_action) { get '/api/v1/me/items', params: params, headers: auth_header }
          else
            let(:do_action) { get "/api/v1/users/#{user.id}/items", params: params, headers: auth_header }
          end

          let!(:items_json) do
            [{
              'id' => 1,
              'name' => 'item 1',
              'description' => 'desc 1',
              'user_id' => 1,
              'done' => false }]
          end

          before do
            do_action
          end

          it 'return 200' do
            expect(response).to have_http_status :ok
          end

          it 'render items json' do
            expect(JSON.parse(response.body)).to eq items_json
          end
        end
      end
    end

    describe "GET /#{endpoint}/items/:id" do
      let!(:item_1) { create(:item, user_id: user.id, name: 'item 1', description: 'desc 1') }

      let!(:item_json) do
        {
          'id' => 1,
          'name' => 'item 1',
          'description' => 'desc 1',
          'user_id' => 1,
          'done' => false }
      end

      if endpoint == 'me'
        let(:do_action) { get "/api/v1/me/items/#{item.id}", headers: auth_header }
      else
        let(:do_action) { get "/api/v1/users/#{user.id}/items/#{item.id}", headers: auth_header }
      end

      context 'unauthenticated' do
        if endpoint == 'me'
          let!(:do_action) { get "/api/v1/me/items/#{item_1.id}" }
        else
          let!(:do_action) { get "/api/v1/users/#{user.id}/items/#{item_1.id}" }
        end

        it 'return 401' do
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'authenticated' do
        context 'querying other user' do
          let!(:other_user) { create(:user) }
          let!(:other_item) { create(:item, user_id: other_user.id) }

          if endpoint != 'me'
            let!(:do_action) { get "/api/v1/users/#{other_user.id}/items/#{other_item.id}", headers: auth_header }

            it 'return 401' do
              expect(response).to have_http_status :unauthorized
            end
          end
        end

        context 'querying other user item' do
          let!(:other_user) { create(:user) }
          let!(:other_item) { create(:item, user_id: other_user.id) }

          if endpoint == 'me'
            let!(:do_action) { get "/api/v1/me/items/#{other_item.id}", headers: auth_header }
          else
            let!(:do_action) { get "/api/v1/users/#{user.id}/items/#{other_item.id}", headers: auth_header }
          end

          it 'return 404' do
            expect(response).to have_http_status :not_found
          end
        end

        context 'querying invalid item' do
          if endpoint == 'me'
            let!(:do_action) { get '/api/v1/me/items/4', headers: auth_header }
          else
            let!(:do_action) { get "/api/v1/users/#{user.id}/items/4", headers: auth_header }
          end

          it 'return 404' do
            expect(response).to have_http_status :not_found
          end
        end

        context 'querying valid item' do
          if endpoint == 'me'
            let!(:do_action) { get "/api/v1/me/items/#{item_1.id}", headers: auth_header }
          else
            let!(:do_action) { get "/api/v1/users/#{user.id}/items/#{item_1.id}", headers: auth_header }
          end

          it 'return 200' do
            expect(response).to have_http_status :ok
          end

          it 'render item json' do
            expect(JSON.parse(response.body)).to eq item_json
          end
        end
      end
    end

    describe "POST /#{endpoint}/items/" do
      if endpoint == 'me'
        let(:do_action) { post '/api/v1/me/items/', headers: auth_header }
      else
        let(:do_action) { post "/api/v1/users/#{user.id}/items/", headers: auth_header }
      end

      let!(:invalid_params) { { item: { name: '', desc: '' } } }

      let!(:missing_name_params) { {} }

      context 'unauthenticated' do
        if endpoint == 'me'
          let!(:do_action) { post '/api/v1/me/items/' }
        else
          let!(:do_action) { post "/api/v1/users/#{user.id}/items/" }
        end

        it 'return 401' do
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'authenticated' do
        context 'creating item with invalid params' do
          context 'missing name' do
            let!(:params) { { item: { desc: 'desc_abc' } } }

            if endpoint == 'me'
              let!(:do_action) { post '/api/v1/me/items/', headers: auth_header, params: params }
            else
              let!(:do_action) { post "/api/v1/users/#{user.id}/items/", headers: auth_header, params: params }
            end

            it 'return 422' do
              expect(response).to have_http_status :unprocessable_entity
            end
          end

          context 'missing description' do
            let!(:params) { { item: { name: 'name_abc' } } }

            if endpoint == 'me'
              let!(:do_action) { post '/api/v1/me/items/', headers: auth_header, params: params }
            else
              let!(:do_action) { post "/api/v1/users/#{user.id}/items/", headers: auth_header, params: params }
            end

            it 'return 422' do
              expect(response).to have_http_status :unprocessable_entity
            end
          end

          context 'missing name and description' do
            let!(:params) { {} }

            if endpoint == 'me'
              let!(:do_action) { post '/api/v1/me/items/', headers: auth_header, params: params }
            else
              let!(:do_action) { post "/api/v1/users/#{user.id}/items/", headers: auth_header, params: params }
            end

            it 'return 422' do
              expect(response).to have_http_status :unprocessable_entity
            end
          end

          context 'empty name and description' do
            let!(:params) { { item: { name: '', description: '' } } }

            if endpoint == 'me'
              let!(:do_action) { post '/api/v1/me/items/', headers: auth_header, params: params }
            else
              let!(:do_action) { post "/api/v1/users/#{user.id}/items/", headers: auth_header, params: params }
            end

            it 'return 422' do
              expect(response).to have_http_status :unprocessable_entity
            end
          end
        end

        context 'creating with other user id' do
          let!(:params) { { item: { name: 'name', description: 'description' } } }

          if endpoint != 'me'
            let!(:do_action) { post '/api/v1/users/2/items/', headers: auth_header, params: params }

            it 'return 401' do
              expect(response).to have_http_status :unauthorized
            end
          end
        end

        context 'creating with valid parameters' do
          let!(:params) { { item: { name: 'name', description: 'description' } } }
          let!(:item_json) do
            {
              'id' => 1,
              'name' => 'name',
              'description' => 'description',
              'user_id' => user.id,
              'done' => false }
          end

          if endpoint == 'me'
            let!(:do_action) { post '/api/v1/me/items/', headers: auth_header, params: params }
          else
            let!(:do_action) { post "/api/v1/users/#{user.id}/items/", headers: auth_header, params: params }
          end

          it 'return 201' do
            expect(response).to have_http_status :created
          end

          it 'render recently created item' do
            expect(JSON.parse(response.body)).to eq item_json
          end

          it 'save in database' do
            expect(Item.count).to eq 1
          end
        end
      end
    end

    describe "PATCH /#{endpoint}/items/:id" do
      context 'unauthenticated' do
        if endpoint == 'me'
          let!(:do_action) { patch '/api/v1/me/items/1' }
        else
          let!(:do_action) { patch "/api/v1/users/#{user.id}/items/1" }
        end

        it 'return 401' do
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'authenticated' do
        context 'invalid item' do
          let!(:params) { { item: {} } }

          if endpoint == 'me'
            let!(:do_action) { patch '/api/v1/me/items/10', params: params, headers: auth_header }
          else
            let!(:do_action) { patch "/api/v1/users/#{user.id}/items/10", params: params, headers: auth_header }
          end

          it 'return 404' do
            expect(response).to have_http_status :not_found
          end
        end

        context 'other user item' do
          let!(:other_user) { create(:user) }
          let!(:item) { create(:item, user_id: other_user.id) }
          let!(:params) { { item: { name: 'name', description: 'description' } } }

          if endpoint != 'me'
            let!(:do_action) { patch "/api/v1/users/#{other_user.id}/items/#{item.id}", params: params, headers: auth_header }

            it 'return 401' do
              expect(response).to have_http_status :unauthorized
            end
          end
        end

        context 'with missing params' do
          let!(:item) { create(:item, user_id: user.id) }
          let!(:params) { { item: {} } }

          if endpoint == 'me'
            let!(:do_action) { patch "/api/v1/me/items/#{item.id}", params: params, headers: auth_header }
          else
            let!(:do_action) { patch "/api/v1/users/#{user.id}/items/#{item.id}", params: params, headers: auth_header }
          end

          it 'return 422' do
            expect(response).to have_http_status :unprocessable_entity
          end
        end

        context 'with empty params' do
          let!(:item) { create(:item, user_id: user.id) }
          let!(:params) { { item: { name: '' } } }

          if endpoint == 'me'
            let!(:do_action) { patch "/api/v1/me/items/#{item.id}", params: params, headers: auth_header }
          else
            let!(:do_action) { patch "/api/v1/users/#{user.id}/items/#{item.id}", params: params, headers: auth_header }
          end

          it 'return 422' do
            expect(response).to have_http_status :unprocessable_entity
          end
        end

        context 'with valid params' do
          let!(:item) { create(:item, user_id: user.id) }
          let!(:params) { { item: { name: 'teste', description: 'teste desc', done: true } } }

          let!(:item_json) do
            {
              'user_id' => user.id,
              'id' => 1,
              'name' => 'teste',
              'description' => 'teste desc',
              'done' => true }
          end

          if endpoint == 'me'
            let!(:do_action) { patch "/api/v1/me/items/#{item.id}", params: params, headers: auth_header }
          else
            let!(:do_action) { patch "/api/v1/users/#{user.id}/items/1", params: params, headers: auth_header }
          end

          it 'return 200' do
            expect(response).to have_http_status :ok
          end

          it 'render recently created item' do
            expect(JSON.parse(response.body)).to eq item_json
          end

          it 'update in database' do
            expect(Item.last.name).to eq 'teste'
            expect(Item.last.description).to eq 'teste desc'
            expect(Item.last.done).to eq true
          end
        end
      end
    end

    describe "DELETE /#{endpoint}/items/:id" do
      context 'unauthenticated' do
        if endpoint == 'me'
          let!(:do_action) { delete '/api/v1/me/items/1' }
        else
          let!(:do_action) { delete "/api/v1/users/#{user.id}/items/1" }
        end

        it 'return 401' do
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'authenticated' do
        context 'invalid item' do
          let!(:params) { { item: {} } }

          if endpoint == 'me'
            let!(:do_action) { delete '/api/v1/me/items/100', headers: auth_header }
          else
            let!(:do_action) { delete "/api/v1/users/#{user.id}/items/100", headers: auth_header }
          end

          it 'return 404' do
            expect(response).to have_http_status :not_found
          end
        end

        context 'other user item' do
          let!(:other_user) { create(:user) }
          let!(:item) { create(:item, user_id: other_user.id) }

          if endpoint != 'me'
            let!(:do_action) { delete "/api/v1/users/#{user.id}/items/#{item.id}", headers: auth_header }

            it 'return 404' do
              expect(response).to have_http_status :not_found
            end
          end
        end

        context 'valid item' do
          let!(:item) { create(:item, user_id: user.id) }

          if endpoint == 'me'
            let!(:do_action) { delete "/api/v1/me/items/#{item.id}", headers: auth_header }
          else
            let!(:do_action) { delete "/api/v1/users/#{user.id}/items/#{item.id}", headers: auth_header }
          end

          it 'return 204' do
            expect(response).to have_http_status :no_content
          end
        end
      end
    end
  end
end
