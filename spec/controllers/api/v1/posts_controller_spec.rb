require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :controller do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:tag) { create(:tag) }
    let(:valid_attributes) do
        {
            title: 'Test Post',
            body: 'This is a test post body',
            tag_list: tag.name
        }
    end
    let(:invalid_attributes) do
        {
            title: '',
            body: '',
            tag_list: ''
        }
    end
    let(:valid_headers) do
        {
        'Authorization' => "Bearer #{generate_token(user)}",
        'Content-Type' => 'application/json'
        }
    end
    let(:other_user_headers) do
        {
        'Authorization' => "Bearer #{generate_token(other_user)}",
        'Content-Type' => 'application/json'
        }
    end

    before do
        request.headers.merge!(valid_headers)
    end

    describe 'POST #create' do
        context 'with valid parameters' do
            it 'creates a new post with tags' do
                expect {
                    post :create, params: { post: valid_attributes }
                }.to change(Post, :count).by(1)
                .and change(PostTag, :count).by(1)

                expect(response).to have_http_status(:created)
                expect(json_response['post']['title']).to eq(valid_attributes[:title])
                expect(json_response['post']['tags'].length).to eq(1)
                expect(json_response['post']['tags'].first['name']).to eq(tag.name)
            end

            it 'creates a new post with multiple tags' do
                attributes = valid_attributes.merge(tag_list: "#{tag.name}, new_tag")
                expect {
                    post :create, params: { post: attributes }
                }.to change(Post, :count).by(1)
                .and change(PostTag, :count).by(2)
                .and change(Tag, :count).by(1)

                expect(response).to have_http_status(:created)
                expect(json_response['post']['tags'].length).to eq(2)
                expect(json_response['post']['tags'].map { |t| t['name'] }).to include(tag.name, 'new_tag')
            end
        end

        context 'with invalid parameters' do
            it 'does not create post with missing required fields' do
                expect {
                    post :create, params: { post: invalid_attributes }
                }.not_to change(Post, :count)

                expect(response).to have_http_status(:unprocessable_entity)
                expect(json_response['errors']).to include("Title can't be blank")
                expect(json_response['errors']).to include("Body can't be blank")
                expect(json_response['errors']).to include("Tags must have at least one tag")
            end

            it 'does not create post without tags' do
                attributes = valid_attributes.merge(tag_list: '')
                expect {
                    post :create, params: { post: attributes }
                }.not_to change(Post, :count)

                expect(response).to have_http_status(:unprocessable_entity)
                expect(json_response['errors']).to include("Tags must have at least one tag")
            end
        end

        context 'unauthorized' do
            before do
                request.headers['Authorization'] = nil
            end

            it 'returns unauthorized without token' do
                post :create, params: { post: valid_attributes }
                expect(response).to have_http_status(:unauthorized)
            end

            it 'returns unauthorized with invalid token' do
                request.headers['Authorization'] = 'Bearer invalid_token'
                post :create, params: { post: valid_attributes }
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'GET #index' do
        before do
            Post.destroy_all
            create_list(:post, 3, user: user, tags: [tag])
        end

        it 'returns all posts' do
            get :index
            expect(response).to have_http_status(:ok)
            expect(json_response['posts'].length).to eq(3)
        end

        it 'filters posts by tag' do
            other_tag = create(:tag)
            create(:post, user: user, tags: [other_tag])

            get :index, params: { tag_id: tag.id }
            expect(response).to have_http_status(:ok)
            expect(json_response['posts'].length).to eq(3)
        end

        it 'returns empty array for non-existent tag' do
            get :index, params: { tag_id: 999999 }
            expect(response).to have_http_status(:ok)
            expect(json_response['posts']).to be_empty
        end

        it 'handles posts with multiple tags correctly' do
            other_tag = create(:tag)
            post_with_multiple_tags = create(:post, user: user, tags: [tag, other_tag])

            get :index, params: { tag_id: tag.id }
            expect(response).to have_http_status(:ok)
            expect(json_response['posts'].map { |p| p['id'] }).to include(post_with_multiple_tags.id)

            get :index, params: { tag_id: other_tag.id }
            expect(response).to have_http_status(:ok)
            expect(json_response['posts'].map { |p| p['id'] }).to include(post_with_multiple_tags.id)
        end
    end

    describe 'GET #show' do
        let(:post) { create(:post, user: user, tags: [tag]) }
        let!(:comment) { create(:comment, post: post, user: other_user) }

        it 'returns the post with tags and comments' do
            get :show, params: { id: post.id }
            expect(response).to have_http_status(:ok)
            expect(json_response['post']['id']).to eq(post.id)
            expect(json_response['post']['tags'].length).to eq(1)
            expect(json_response['post']['comments'].length).to eq(1)
        end

        it 'returns not found for non-existent post' do
            get :show, params: { id: 0 }
            expect(response).to have_http_status(:not_found)
        end

        it 'handles post with no comments' do
            post_without_comments = create(:post, user: user, tags: [tag])
            get :show, params: { id: post_without_comments.id }
            expect(response).to have_http_status(:ok)
            expect(json_response['post']['comments']).to be_empty
        end
    end

    describe 'PUT #update' do
        let(:post) { create(:post, user: user, tags: [tag]) }
        let(:new_tag) { create(:tag) }
        let(:new_attributes) do
            {
                title: 'Updated Title',
                body: 'Updated body',
                tag_list: new_tag.name
            }
        end

        context 'when user is the author' do
            it 'updates the post' do
                put :update, params: { id: post.id, post: new_attributes }
                expect(response).to have_http_status(:ok)
                expect(json_response['post']['title']).to eq('Updated Title')
                expect(json_response['post']['tags'].first['name']).to eq(new_tag.name)
            end

            it 'updates only the tags' do
                put :update, params: { id: post.id, post: { tag_list: new_tag.name } }
                expect(response).to have_http_status(:ok)
                expect(json_response['post']['tags'].first['name']).to eq(new_tag.name)
                expect(json_response['post']['title']).to eq(post.title)
            end

            it 'updates with multiple tags' do
                put :update, params: { id: post.id, post: { tag_list: "#{new_tag.name}, another_tag" } }
                expect(response).to have_http_status(:ok)
                expect(json_response['post']['tags'].length).to eq(2)
                expect(json_response['post']['tags'].map { |t| t['name'] }).to include(new_tag.name, 'another_tag')
            end

            it 'handles update with empty tag list' do
                put :update, params: { id: post.id, post: { tag_list: '' } }
                expect(response).to have_http_status(:unprocessable_entity)
                expect(json_response['errors']).to include("Tags must have at least one tag")
            end

            it 'handles post with no comments' do
                post_without_comments = create(:post, user: user, tags: [tag])
                get :show, params: { id: post_without_comments.id }
                expect(response).to have_http_status(:ok)
                expect(json_response['post']['comments']).to be_empty
            end

            it 'validates title length' do
                long_title = 'a' * 256
                put :update, params: { id: post.id, post: { title: long_title } }
                expect(response).to have_http_status(:unprocessable_entity)
                expect(json_response['errors']).to include("Title is too long (maximum is 255 characters)")
            end

            it 'handles update with special characters in tags' do
                put :update, params: { id: post.id, post: { tag_list: "tag@123, tag#456" } }
                expect(response).to have_http_status(:ok)
                expect(json_response['post']['tags'].map { |t| t['name'] }).to include("tag@123", "tag#456")
            end
        end

        context 'when user is not the author' do
            before { request.headers.merge!(other_user_headers) }

            it 'returns unauthorized' do
                put :update, params: { id: post.id, post: new_attributes }
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'DELETE #destroy' do
        let!(:post) { create(:post, user: user, tags: [tag]) }

        context 'when user is the author' do
            it 'deletes the post' do
                expect {
                delete :destroy, params: { id: post.id }
                }.to change(Post, :count).by(-1)
                .and change(PostTag, :count).by(-1)

                expect(response).to have_http_status(:no_content)
            end
        end

        context 'when user is not the author' do
            before { request.headers.merge!(other_user_headers) }

            it 'returns unauthorized' do
                expect {
                delete :destroy, params: { id: post.id }
                }.not_to change(Post, :count)

                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'Automatic deletion' do
        it 'deletes posts older than 24 hours' do
            old_post = create(:post, user: user, tags: [tag], created_at: 25.hours.ago)

            expect {
                Post.cleanup_old_posts
            }.to change(Post, :count).by(-1)

            expect { old_post.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'keeps posts newer than 24 hours' do
            new_post = create(:post, user: user, tags: [tag], created_at: 23.hours.ago)

            expect {
                Post.cleanup_old_posts
            }.not_to change(Post, :count)

            expect { new_post.reload }.not_to raise_error
        end
    end
end
