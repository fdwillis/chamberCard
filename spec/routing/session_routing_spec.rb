# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :routing do
  describe 'routing' do
    context 'at minimum', minimum: true do
      it 'routes to login' do
        expect(get: '/auth/login').to route_to('sessions#new')
      end

      it 'routes to logout' do
        expect(get: '/auth/logout').to route_to('sessions#destroy')
      end
    end
  end
end
