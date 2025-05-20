module Api
  module V1
    class TagsController < ApplicationController
      def index
        @tags = Tag.all
        render json: @tags
      end

      def create
        @tag = Tag.new(tag_params)

        if @tag.save
          render json: @tag, status: :created
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def tag_params
        params.require(:tag).permit(:name)
      end
    end
  end
end