# frozen_string_literal: true

module APIClients
  class APIClient
    # @param api_base_path [String] Base path to the API
    def initialize(api_base_path:)
      @api_base_path = api_base_path
    end

    private

    def make_request(endpoint:)
      uri = URI(URI.join(@api_base_path, endpoint))

      response = Net::HTTP.get_response(uri)

      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
