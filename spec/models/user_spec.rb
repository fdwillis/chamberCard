# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'at minimum', minimum: true do
    it 'should have many posts as the inverse of author' do
      should respond_to(:id)
    end
  end
end
