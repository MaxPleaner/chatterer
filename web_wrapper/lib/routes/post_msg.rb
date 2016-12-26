class Routes::PostMsg

  def self.run(request)
    http_request request
  end

  def self.http_request request
    SharedServerDispatcher.input.push params[:msg]
    request.set_status_code 204
  end

end
