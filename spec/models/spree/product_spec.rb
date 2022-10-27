require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  let(:product) { create(:spree_product, server_type: 'reseller_plan') }

  it "is valid with valid attributes" do
    expect(product.reseller_plan?).to be true
  end

  it "is valid with valid attributes" do
    expect(product).to be_valid
  end

  it "is not valid without a name" do
    product.name = nil
    expect(product).to_not be_valid
  end

  it "is not valid without a server_type" do
    product.server_type = nil
    expect(product).to_not be_valid
  end
  
  it "is not valid without a price" do
    product.price = nil
    expect(product).to_not be_valid
  end

end
