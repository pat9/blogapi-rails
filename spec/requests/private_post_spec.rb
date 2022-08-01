require "rails_helper"

RSpec.describe "Posts with authentication", type: :request do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:user_post) { create(:post, user_id: user.id) }
    let!(:other_user_post) { create(:post, user_id: other_user.id, published: true) }
    let!(:other_user_post_draft) { create(:post, user_id: other_user.id, published: false) }
    let!(:auth_headers) { {'Authorizaiton' => "Bearer #{user.auth_token}"} }
    let!(:other_auth_headers) { {'Authorizaiton' => "Bearer #{other_user.auth_token}"} }
    #Authorization: Bearer XXXXXXX

    describe "GET /posts/{id}" do
        context "with valid auth" do
            context "when request other's post author" do
                context "post is public" do
                    before { get "/posts/#{other_user_post.id}", headers: auth_headers }
                    #Payload
                    context "payload" do
                        subject {JSON.parse(response.body)}
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
                        subject {JSON.parse(response.body)}
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
    describe "POST /posts/{id}" do
    
    end
    describe "PUT /posts/{id}" do
    
    end
    # it "should return OK" do
    #     get '/posts'
    #     payload = JSON.parse(response.body)
    #     expect(payload).to be_empty
    #     expect(response).to have_http_status(200)
    # end 
end