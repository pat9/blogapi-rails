class PostSearchService
    def self.search(curr_post, query)
        posts_ids = Rails.cache.fetch("posts_search", expires_in: 1.hours) do
            curr_post.where("title like '%#{query}%'").map(&:id)
        end
        curr_post.where(id: posts_ids)
    end
end