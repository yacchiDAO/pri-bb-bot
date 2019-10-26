require 'uri'
require 'active_support'
require 'active_support/core_ext'
require 'rest-client'

class NiconicoPribbExtractor
  def initialize
    @niconico_url = 'https://api.search.nicovideo.jp/api/v2/video/contents/search'
    @header = { 'User-Agent': ENV['USER-AGENT'] }
    @params = {
      'q': '',
      '_offset': '1',
      'targets': 'tagsExact',
      '_sort': 'startTime',
      'fields': 'contentId,title',
      '_context': ENV['_CONTEXT'],
      '_limit': '100'
    }
    @limit = 100
  end

  def all_contents
    contents = []
    contents += pribb_contents('prichan') || []
    contents += pribb_contents('pripara') || []
    contents.each_with_object([]) do |content, arr|
      arr << { 'id' => content['contentId'], 'title' => content['title'] }
    end
  end

  private

  def pribb_contents(product)
    q = case product
    when 'pripara'
      'プリパラBBシリーズ'
    when 'prichan'
      'プリチャンBBシリーズ'
    else
      return nil
    end

    uri = URI(@niconico_url)
    offset = 1
    results =  []
    begin
      while 1
        @params[:q] = q
        @params[:_offset] = offset.to_s
        uri.query = @params.to_param
        res = JSON.parse(RestClient.get(uri.to_s, @header))
        results += res['data']
        break if (res['meta']['totalCount'] - offset * @limit) <= 0
        offset += 1
        sleep(1)
      end
    rescue => e
      puts e
      raise
    end
    results
  end
end