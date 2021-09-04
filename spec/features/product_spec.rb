require "rails_helper"

RSpec.feature "product management", :type => :feature do
  let(:managerStripe) {FactoryBot.create(:managerStripe)}

  scenario "manager accessPin type creates a new product" do
    visit "/auth/login"

    fill_in "Email", :with => managerStripe.email
    fill_in "Password", :with => managerStripe.password
    click_button "Login"
    expect(page).to have_text("Welcome")


    visit "/products"
    click_link "Add Product"
    # expect(find_field("product_images[]").visible?).to eq(true)
    expect(find_field("product_name").visible?).to eq(true)
    expect(find_field("product_stockCount").visible?).to eq(true)
    expect(find_field("product_description").visible?).to eq(true)
    fill_in('product_name', :with => 'John')
    fill_in('product_stockCount', :with => '13')
    fill_in('product_description', :with => 'description')
    click_button "Add Product"
    expect(page).to have_content('Created')
  end
end 