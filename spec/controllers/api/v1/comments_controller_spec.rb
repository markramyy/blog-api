require 'rails_helper'

RSpec.describe Api::V1::CommentsController, type: :controller do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:post_record) { create(:post, user: user) }
    let!(:comment) { create(:comment, post: post_record, user: user) }
    let(:valid_headers) do
        { 'Authorization' => "Bearer #{generate_token(user)}", 'Content-Type' => 'application/json' }
    end
    let(:other_user_headers) do
        { 'Authorization' => "Bearer #{generate_token(other_user)}", 'Content-Type' => 'application/json' }
    end

    before do
        request.headers.merge!(valid_headers)
    end

    describe 'Create comment' do
        context 'Valid comment creation' do
            it 'creates a new comment' do
                expect {
                post :create, params: { post_id: post_record.id, comment: { content: 'A valid comment' } }
                }.to change(Comment, :count).by(1)
                expect(response).to have_http_status(:created)
                expect(JSON.parse(response.body)['content']).to eq('A valid comment')
            end
        end

        context 'Invalid comment creation' do
            it 'does not create a comment with blank content' do
                expect {
                post :create, params: { post_id: post_record.id, comment: { content: '' } }
                }.not_to change(Comment, :count)
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['errors']).to include("Content can't be blank")
            end
        end

        context 'Unauthorized comment creation' do
            it 'returns unauthorized without token' do
                request.headers['Authorization'] = nil
                post :create, params: { post_id: post_record.id, comment: { content: 'Unauthorized comment' } }
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'Update comment' do
        context 'Valid update (author)' do
            it 'updates a comment' do
                patch :update, params: { post_id: post_record.id, id: comment.id, comment: { content: 'Updated comment' } }
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)['content']).to eq('Updated comment')
            end
        end

        context 'Invalid update (non-author)' do
            it 'returns forbidden if not the author' do
                request.headers.merge!(other_user_headers)
                patch :update, params: { post_id: post_record.id, id: comment.id, comment: { content: 'Unauthorized update' } }
                expect(response).to have_http_status(:forbidden)
            end
        end
    end

    describe 'Delete comment' do
        context 'Valid deletion (author)' do
            it 'deletes a comment' do
                expect {
                delete :destroy, params: { post_id: post_record.id, id: comment.id }
                }.to change(Comment, :count).by(-1)
                expect(response).to have_http_status(:no_content)
            end
        end

        context 'Unauthorized deletion' do
            it 'returns forbidden if not the author' do
                request.headers.merge!(other_user_headers)
                expect {
                delete :destroy, params: { post_id: post_record.id, id: comment.id }
                }.not_to change(Comment, :count)
                expect(response).to have_http_status(:forbidden)
            end
        end
    end
end
