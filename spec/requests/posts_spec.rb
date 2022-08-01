
require "rails_helper"

RSpec.describe "Posts", type: :request do
    describe "GET /posts" do
        it "should return OK" do
            get '/posts'
            payload = JSON.parse(response.body)
            expect(payload).to be_empty
            expect(response).to have_http_status(200)
        end 

        describe "search" do
            let!(:hola_mundo) { create(:published_post, title: 'Hola mundo') }
            let!(:hola_rails) { create(:published_post, title: 'Hola rails') }
            let!(:curso_rails) { create(:published_post, title: 'Curso rails') }
            it "should return by title" do
                get "/posts?search=Hola"
                payload = JSON.parse(response.body)
                expect(payload).to_not be_empty
                expect(payload.size).to eq(2)
                expect(payload.map {|p| p["id"]}.sort).to eq([hola_mundo["id"], hola_rails["id"]].sort)
                expect(response).to have_http_status(200)
            end
        end
    end
    

    describe "with data in the DB" do
        let!(:posts) { create_list(:post, 10, published:true) }
        before { get '/posts' }

        it "shoud return all published post" do
            payload = JSON.parse(response.body)
            expect(payload.size).to eq(posts.size)
            expect(response).to have_http_status(200)
        end
    end

    describe "GET /posts/:id" do
        let!(:post) { create(:post, published: true) }
        
        it "shoud return one post" do
            get "/posts/#{post.id}"

            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload["id"]).to eq(post.id)
            expect(payload["title"]).to eq(post.title)
            expect(payload["content"]).to eq(post.content)
            expect(payload["published"]).to eq(post.published)
            expect(payload["author"]["name"]).to eq(post.user.name)
            expect(payload["author"]["email"]).to eq(post.user.email)
            expect(payload["author"]["id"]).to eq(post.user.id)
            expect(response).to have_http_status(200)
        end
    end

end
