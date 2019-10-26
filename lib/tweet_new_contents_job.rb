require_relative 'contents_store.rb'
require_relative 'tweet_client.rb'
require_relative 'tweet_content.rb'
require_relative 'niconico_pribb_extractor.rb'

class TweetNewContentsJob
  include TweetContent

  def perform
    # APIからすべての動画を取得
    new_contents = NiconicoPribbExtractor.new.all_contents
    # Redisを参照して差分を確認
    store = ContentsStore.new
    old_contents = store.all_contents

    add_contents = content_diff(new_contents, old_contents)
    deleted_contents = content_diff(old_contents, new_contents)

    # 差分があったものをツイート
    new_contents_tweet(add_contents) if add_contents.size > 0
    # Redisに新規保存
    store.reset_contents(new_contents) if add_contents.size > 0 || deleted_contents.size > 0
  end

  private

  def new_contents_tweet(contents)
    new_content_text = '新たに動画が追加されました\n'
    contents[0..9].each_with_object(new_content_text) do |content, text|
      text += "#{content['title']}:#{@url}#{content['id']}\n"
    end
    tweet_content(new_content_text)
  end

  def content_diff(content_list_1, content_list_2)
    content_list_2_ids = content_list_2.map { |content| content['id'] }
    content_list_1.each_with_object([]) do |content, arr|
      arr << content unless content_list_2_ids.include?(content['id'])
    end
  end
end

TweetNewContentsJob.new.perform