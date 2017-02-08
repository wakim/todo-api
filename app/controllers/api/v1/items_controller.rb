module Api
  module V1
    class ItemsController < ApplicationController
      before_action :check_user
      before_action :set_item, only: [:show, :update, :destroy]

      def index
        page = params[:page]

        @items = @user.items unless page.present?
        @items = @user.items.page(page).per(params[:per] || 1) if page.present?

        render json: @items, except: [:created_at, :updated_at]
      end

      def show
        render json: @item, except: [:created_at, :updated_at]
      end

      def create
        @item = @user.items.create(item_params)

        if @item.save
          render json: @item, status: :created, location: api_v1_user_item_path(@user, @item), except: [:created_at, :updated_at]
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render status: :unprocessable_entity
      end

      def update
        if @item.update(item_params)
          render json: @item, except: [:created_at, :updated_at]
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render status: :unprocessable_entity
      end

      def destroy
        @item.destroy
      end

      private

      def set_item
        @item = @user.items.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render status: :not_found
      end

      def item_params
        params.require(:item).permit(:name, :description, :done)
      end

      def check_user
        if params[:user_id] == 'me' && current_user
          @user = current_user
        elsif params[:user_id].to_i != @current_user.id
          render json: { error: 'Not Authorized' }, status: :unauthorized
        else
          @user = current_user
        end
      end
    end
  end
end
