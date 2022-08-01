class PostReportJob < ApplicationJob
  queue_as :default

  def perform(user_id, post_id)
    user = User.find(user_id)
    post = Post.find(post_id)
    PostReport.generate(post)
    # Do something later
    # user -> report -> emails
  end
end
