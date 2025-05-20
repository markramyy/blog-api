module Api
  module V1
    class TagsController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

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

      def destroy
        post = Post.find(params[:post_id])
        tag = Tag.find(params[:id])
        if post.authored_by?(current_user)
          post.tags.destroy(tag)
          head :no_content
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      private

      def tag_params
        params.require(:tag).permit(:name)
      end

      def not_found
        render json: { error: 'Not found' }, status: :not_found
      end
    end
  end
end