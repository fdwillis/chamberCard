require 'oj'

def response_json(passed)
  Oj.load(passed)
end

def response_body_json
  Oj.load(response.body)
end

def set_headers(auth_token)
  if auth_token
    {
      'bxxkxmxppAuthtoken' => auth_token, 
      'appName' => 'testRSPEC', 
      'Content-Type' => 'application/json',
    }
  else
    {
      'appName' => 'testRSPEC', 
      'Content-Type' => 'application/json',
    } 
  end
end

def destroy_api(route, headers, params)
  if headers
    delete route, headers: set_headers(headers), params: params
  else
    delete route, params: params
  end
end

def put_api(route, headers, params)
  if headers
    put route, headers: set_headers(headers), params: params
  else
    put route, params: params
  end
end

def patch_api(route, headers, params)
  if headers
    patch route, headers: set_headers(headers), params: params
  else
    patch route, params: params
  end
end

def post_api(route, headers, params)
  if headers
    post route, headers: set_headers(headers), params: params
  else
    post route, params: params
  end
end

def get_api(route, headers, params)
  if headers
    get route, headers: set_headers(headers), params: params
  else
    get route, params: params
  end
end