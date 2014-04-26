
module ResponseHelpers
  def successful_response
    raw_response = double(RESPONSE_FIELDS)
    response = Balancir::Response.new
    response.parse(raw_response)
    response
  end

  def failed_response
    response = Balancir::Response.new
    response.exception = StandardError.new
    response
  end
end

