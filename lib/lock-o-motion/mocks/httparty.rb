module HTTParty
  extend self

  def get(path, options = {}, &block)
    url = NSURL.URLWithString path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    request = NSURLRequest.requestWithURL url
    data = NSURLConnection.sendSynchronousRequest request, returningResponse: nil, error: nil
    NSString.alloc.initWithData data, encoding: NSUTF8StringEncoding
  end

  def post(path, options = {}, &block)

  end

  def put(path, options = {}, &block)

  end

  def delete(path, options = {}, &block)

  end

end