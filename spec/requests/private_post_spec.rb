require "rails_helper"

RSpec.describe "Posts with authentication", type: :request do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:user_post) { create(:post, user_id: user.id) }
    let!(:other_user_post) { create(:post, user_id: other_user.id, published: true) }
    let!(:other_user_post_draft) { create(:post, user_id: other_user.id, published: false) }
    let!(:auth_headers) { {'Authorization' => "Bearer #{user.auth_token}"} }
    let!(:other_auth_headers) { {'Authorization' => "Bearer #{other_user.auth_token}"} }
    let!(:create_params) {  {"post" => { "title" => "title", "content" => "content", "published" => true } }}
    let!(:update_params) {  {"post" => { "title" => "title", "content" => "content", "published" => true } }}
    #Authorization: Bearer XXXXXXX

    describe "GET /posts/{id}" do
        context "with valid auth" do
            context "when request other's post author" do
                context "post is public" do
                    before { get "/posts/#{other_user_post.id}", headers: auth_headers }
                    #Payload
                    context "payload" do
                        subject { payload }
                        it {is_expected.to include(:id) }
                    end
                    #Status :ok
                    context "response" do
                        subject {response}
                        it {is_expected.to have_http_status(:ok) }
                    end
                end
                context "post is draft" do
                    before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }
                    #Payload
                    context "payload" do
                        subject { payload }
                        it {is_expected.to include(:error) }
                    end
                    #Status :ok
                    context "response" do
                        subject {response}
                        it {is_expected.to have_http_status(:not_found) }
                    end
                end
            end
            context "when request user's post" do
            end

        end
    end
    describe "POST /posts" do
        context "with auth" do
            before { post "/posts", params: create_params, headers: auth_headers }
            #Payload
            context "payload" do
                subject { payload }
                it {is_expected.to include(:id, :content, :published, :author) }
            end
            #Status :ok
            context "response" do
                subject {response}
                it {is_expected.to have_http_status(:created) }
            end
        end
        context "without auth" do
            before { post "/posts", params: create_params }
            #Payload
            context "payload" do
                subject { payload }
                it {is_expected.to include(:error) }
            end
            #Status :ok
            context "response" do
                subject {response}
                it {is_expected.to have_http_status(:unauthorized) }
            end
        end
    end
    describe "PUT /posts/{id}" do
        context "with auth" do
            context "when updating user's post" do
                before { put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }
                #Payload
                context "payload" do
                    subject { payload }
                    it {is_expected.to include(:id, :content, :published, :author) }
                    it { expect(payload[:id]).to eq(user_post.id) }
                end
                #Status :ok
                context "response" do
                    subject { response }
                    it {is_expected.to have_http_status(:ok) }
                end
            end
            context "when updating other's user post" do
                before { put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }
                #Payload
                context "payload" do
                    subject { payload }
                    it {is_expected.to include(:error) }
                end
                #Status :not_found
                context "response" do
                    subject { response }
                    it {is_expected.to have_http_status(:not_found) }
                end
            end
        end
    end

    private
    def payload
        JSON.parse(response.body).with_indifferent_access
    end

end