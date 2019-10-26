require 'redis'
require 'json'

class ContentsStore
  def initialize
    redis_url = ENV['REDIS_URL']
    @redis = redis_url.nil? ? Redis.new(host: 'localhost', port: '6379') : Redis.new(url: redis_url)
    @redis.ping
  end

  def all_contents
    @redis.lrange('contents', 0, -1).map { |c| JSON.parse(c) }
  end

  def content_ids
    all_contents.map { |a| a['id'] }
  end

  def push_content(content)
    ids = content_ids
    return if content['id'].nil? || content['title'].nil? || ids.include?(content['id'])
    @redis.rpush('contents', content.to_json)
  end

  def reset_contents(contents)
    @redis.del('contents')
    contents.each { |content| push_content(content) }
  end
end
