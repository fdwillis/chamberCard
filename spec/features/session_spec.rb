require "rails_helper"

RSpec.feature "Session management", :type => :feature do
  let(:customerStripe) {FactoryBot.create(:customerStripe)}

  scenario "User creates a new session" do
    visit "/auth/login"

    fill_in "Email", :with => customerStripe.email
    fill_in "Password", :with => customerStripe.password
    click_button "Login"
    expect(page).to have_text("Welcome")
  end
end