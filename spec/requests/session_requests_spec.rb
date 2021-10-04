# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Session', type: :request, minimum: true do
  # fixtures :posts

  context 'at minimum', minimum: true do
    describe 'GET auth/login' do
      it 'returns http success' do
        get '/auth/login'
        expect(response).to be_successful
      end
    end

    # describe 'GET /:post_datestamp/:post_id' do
    #   it 'renders a successful response' do
    #     post = posts(:by_user_one)
    #     get "/#{post.created_at.to_date.iso8601}/#{post.id}"
    #     expect(response).to be_successful
    #   end
    # end
  end
end
