# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :routing do
  describe 'routing' do
    context 'at minimum', minimum: true do
      it 'routes to login' do
        expect(get: '/auth/login').to route_to('sessions#new')
      end

      # it 'routes to #show_post' do
      #   expect(get: '/2020-01-01/1').to route_to('home#show_post', iso8601_datestamp: '2020-01-01', id: '1')
      # end
    end
  end
end
