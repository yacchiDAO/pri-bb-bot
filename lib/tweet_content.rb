module TweetContent
  def initialize
    @url = 'https://nico.ms/'
  end

  private

  def tweet_content(text)
    TweetClient.new(text).send_tweet
  end
end