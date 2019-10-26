require_relative 'contents_store.rb'
require_relative 'tweet_client.rb'
require_relative 'tweet_content.rb'

class TweetRandomContentJob
  include TweetContent

  def perform
    contents = ::ContentsStore.new.all_contents
    return if contents.size <= 0
    random_tweet(contents.sample)
  end

  private

  def random_tweet(content)
    text = "#{content['title']}\n#{@url}#{content['id']}"
    tweet_content(text)
  end
end

TweetRandomContentJob.new.perform