module Api
  module V1
    class UsersController < ApplicationController
      swagger_controller :users, 'Users'

      swagger_api :show do
        summary 'Return user info'
      end

      def show
        id = params[:id]

        if id != 'me' && id.to_i != @current_user.id
          render status: 404
        else
          render json: @current_user.attributes.slice('id', 'name', 'email')
        end
      end
    end
  end
end
