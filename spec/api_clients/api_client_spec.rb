# frozen_string_literal: true

require 'ynab_convert/api_clients/api_client'

RSpec.describe APIClients::APIClient do
  let(:subject) { APIClients::APIClient.new }

  it 'instantiates' do
    expect(subject).to be_an_instance_of(APIClients::APIClient)
  end
end
