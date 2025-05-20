module Api
  module V1
    class PostsController < ApplicationController
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :authorize_post_owner, only: [:update, :destroy]
      before_action :authenticate_user!

      def index
        @posts = Post.includes(:user, :tags).all
        @posts = @posts.joins(:tags).where(tags: { id: params[:tag_id] }) if params[:tag_id]
        render json: { posts: @posts.as_json(
          include: {
            user: { only: [:id, :name, :email, :image] },
            tags: { only: [:id, :name] }
          }
        ) }
      end

      def show
        render json: { post: @post.as_json(
          include: {
            user: { only: [:id, :name, :email, :image] },
            tags: { only: [:id, :name] },
            comments: {
              include: { user: { only: [:id, :name, :email, :image] } }
            }
          }
        ) }
      end

      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          render json: { post: @post.as_json(
            include: {
              user: { only: [:id, :name, :email, :image] },
              tags: { only: [:id, :name] }
            }
          ) }, status: :created
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @post.update(post_params)
          render json: { post: @post.as_json(
            include: {
              user: { only: [:id, :name, :email, :image] },
              tags: { only: [:id, :name] }
            }
          ) }
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
          render json: { error: "You are not authorized to perform this action" }, status: :unauthorized
        end
      end

      def authenticate_user!
        unless current_user
          render json: { error: 'Unauthorized' }, status: :unauthorized
          return
        end
      end
    end
  end
end