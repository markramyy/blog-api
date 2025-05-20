module Api
  module V1
    class PostsController < ApplicationController
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :authorize_post_owner, only: [:update, :destroy]

      def index
        @posts = Post.includes(:user, :tags).all
        render json: @posts.as_json(
          include: {
            user: { only: [:id, :name, :email, :image] },
            tags: { only: [:id, :name] }
          }
        )
      end

      def show
        render json: @post.as_json(
          include: {
            user: { only: [:id, :name, :email, :image] },
            tags: { only: [:id, :name] }
          }
        )
      end

      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          render json: @post.as_json(
            include: {
              user: { only: [:id, :name, :email, :image] },
              tags: { only: [:id, :name] }
            }
          ), status: :created
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @post.update(post_params)
          render json: @post.as_json(
            include: {
              user: { only: [:id, :name, :email, :image] },
              tags: { only: [:id, :name] }
            }
          )
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @post.destroy
        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      def post_params
        params.require(:post).permit(:title, :body, :tag_list)
      end

      def authorize_post_owner
        unless @post.authored_by?(current_user)
          render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
      end
    end
  end
end