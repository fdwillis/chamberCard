# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Session', type: :request, minimum: true do
  # fixtures :posts

  context 'at minimum', minimum: true do
    describe 'GET home' do
      it 'returns http success' do
        get_api("/", nil, nil)
        expect(response).to be_successful
      end
    end

    describe 'GET auth/login' do
      it 'returns http success' do
        get_api("/auth/login", nil, nil)
        expect(response).to be_successful
      end
    end
  end
end
