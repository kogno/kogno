require 'wit'
class Wit


  def initialize(opts = {})
    @access_token = opts[:access_token]
    @api_version = opts[:api_version] || "20210928"

    if opts[:logger]
      @logger = opts[:logger]
    end
  end

  def message_with_context(msg, context=nil)
    params = {}
    params[:q] = msg unless msg.nil?
    params[:context] = context.to_json unless context.nil?
    res = req(logger, @access_token, Net::HTTP::Get, '/message', params)
    return res
  end

  def entity_create(params) # extras = {roles: [], keywords: [], lookups: []}
    res = req(logger, @access_token, Net::HTTP::Post, "/entities", {}, params)
    return res
  end

  def entity_keyword_add(name, role, keyword, synonyms)
    res = req(logger, @access_token, Net::HTTP::Post, "/entities/#{name}/keywords", {}, {keyword: keyword, synonyms: synonyms})
    return res
  end

  def entity_keyword_remove(name, keyword)
    res = req(logger, @access_token, Net::HTTP::Delete, "/entities/#{name}/keywords/#{keyword}")
    return res    
  end

  def req(logger, access_token, meth_class, path, params={}, payload={})
    uri = URI(WIT_API_HOST + path)
    uri.query = URI.encode_www_form(params)
    # logger.debug uri, :green
    request = meth_class.new(uri)
    request['authorization'] = 'Bearer ' + access_token
    request['accept'] = 'application/vnd.wit.' + @api_version + '+json'
    request.add_field 'Content-Type', 'application/json'
    request.body = payload.to_json
    # logger.debug request, :yellow
    Net::HTTP.start(uri.host, uri.port, {:use_ssl => uri.scheme == 'https'}) do |http|
      rsp = http.request(request)
      json = JSON.parse(rsp.body)
      if rsp.code.to_i != 200
        error_msg = (json.is_a?(Hash) and json.has_key?('error')) ?  json['error'] : json
        logger.write "Wit.ai responded with an error: #{error_msg}", :red
        raise Error.new("Wit.ai responded with an error: #{error_msg}")
      end
      # logger.debug("#{meth_class} #{uri} #{json}")
      json
    end
  end

end
