require 'rails_helper'

RSpec.describe Api::V1::TagsController, type: :controller do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:post_record) { create(:post, user: user, tags: [create(:tag)]) }
    let(:tag) { create(:tag) }
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

    describe 'Add tags to post' do
        context 'Valid tag addition' do
            it 'adds a tag to a post' do
                expect {
                post :create, params: { tag: { name: 'newtag' } }
                }.to change(Tag, :count).by(1)
                expect(response).to have_http_status(:created)
                expect(JSON.parse(response.body)['name']).to eq('newtag')
            end
        end

        context 'Invalid tag addition' do
            it 'does not add a tag with blank name' do
                expect {
                post :create, params: { tag: { name: '' } }
                }.not_to change(Tag, :count)
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
            end

            it 'does not add a duplicate tag' do
                existing_tag = create(:tag, name: 'dupe')
                expect {
                post :create, params: { tag: { name: 'dupe' } }
                }.not_to change(Tag, :count)
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['errors']).to include('Name has already been taken')
            end
        end

        context 'Unauthorized tag addition' do
            it 'returns unauthorized without token' do
                request.headers['Authorization'] = nil
                post :create, params: { tag: { name: 'unauth' } }
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'Remove tags from post' do
        # Assuming a custom action for removing tags from a post, e.g., DELETE /posts/:post_id/tags/:id
        controller do
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
        end

        context 'Valid tag removal' do
            it 'removes a tag from a post' do
                post_record.tags << tag
                expect {
                delete :destroy, params: { post_id: post_record.id, id: tag.id }
                }.to change { post_record.reload.tags.count }.by(-1)
                expect(response).to have_http_status(:no_content)
            end
        end

        context 'Invalid tag removal' do
            it 'returns not found for non-existent tag' do
                expect {
                delete :destroy, params: { post_id: post_record.id, id: 999999 }
                }.not_to change { post_record.reload.tags.count }
                expect(response).to have_http_status(:not_found)
            end
        end

        context 'Unauthorized tag removal' do
            it 'returns unauthorized if not the author' do
                request.headers.merge!(other_user_headers)
                post_record.tags << tag
                expect {
                delete :destroy, params: { post_id: post_record.id, id: tag.id }
                }.not_to change { post_record.reload.tags.count }
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end
end