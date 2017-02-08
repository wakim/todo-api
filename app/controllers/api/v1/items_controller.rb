module Api
  module V1
    class ItemsController < ApplicationController
      before_action :check_user
      before_action :set_item, only: [:show, :update, :destroy]

      swagger_controller :items, 'Items'

      swagger_api :index do
        summary 'Return current user items'
        param :query, :page, :integer, :optional, 'Page number'
        param :per, :integer, :optional, 'Items per page'
        response :ok, :Items
      end

      def index
        @items = @user.items unless params[:page].present?
        @items = @user.items.page(params[:page]).per(params[:per] || 1) if params[:page].present?

        render json: @items, except: [:created_at, :updated_at]
      end

      swagger_api :show do
        summary 'Return detail for current user item'
        response :ok, :Item
      end

      def show
        render json: @item, except: [:created_at, :updated_at]
      end

      swagger_api :create do
        summary 'Create an item for the current user'
        param 'item[name]', :string, 'Item name'
        param 'item[description]', :string, 'Item description'
        param 'item[done]', :boolean, :optional, 'Item status'
        response :created, :Item
        response :unprocessable_entity, 'When missing parameters'
        response :not_authorized
      end

      def create
        @item = @user.items.create(item_params)

        if @item.save
          render json: @item, status: :created, location: api_v1_user_item_path(@user, @item), except: [:created_at, :updated_at]
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render status: 422
      end

      swagger_api :update do
        summary 'Update an item for the current user'
        param 'item[name]', :string, :optional, 'Item name'
        param 'item[description]', :string, :optional, 'Item description'
        param 'item[done]', :boolean, :optional, 'Item status'
        response :ok
        response :not_authorized
        response :unprocessable_entity, 'With invalid parameters'
        response :not_found
      end

      def update
        if @item.update(item_params)
          render json: @item, except: [:created_at, :updated_at]
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render status: 422
      end

      swagger_api :destroy do
        summary 'Destroy an item for the current user'
        response :not_authorized
        response :no_content
        response :not_found
      end

      def destroy
        @item.destroy
      end

      private

      def set_item
        @item = @user.items.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render status: 404
      end

      def item_params
        params.require(:item).permit(:name, :description, :done)
      end

      def check_user
        if params[:user_id] == 'me' && current_user
          @user = current_user
        elsif params[:user_id].to_i != @current_user.id
          render json: { error: 'Not Authorized' }, status: 401
        else
          @user = current_user
        end
      end
    end
  end
end
