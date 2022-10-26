require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  let(:product) { create(:spree_product, server_type: 'reseller_plan') }

  it "check server type is reseller" do
    expect(product.server_type).to include("reseller_plan")
  end

  it "check server type is hsphere" do
    expect(product.server_type).to include("hsphere")
  end

  it "check server type is domain" do
    expect(product.server_type).to include("domain")
  end

  it "check server type is windows" do
    expect(product.server_type).to include("windows")
  end

  it "check server type is linux" do
    expect(product.server_type).to include("linux")
  end

  it "is valid with valid attributes" do
    expect(product).to be_valid
  end

  it "is not valid without a name" do
    product.name = nil
    expect(product).to_not be_valid
  end

  it "fails on nil product name" do
    product.name = nil
    expect(product).to be_valid
  end

  it "is not valid without a server_type" do
    product.server_type = nil
    expect(product).to_not be_valid
  end
  
  it "is not valid without a price" do
    product.price = nil
    expect(product).to_not be_valid
  end

  it "fails on nil product price" do
    product.price = nil
    expect(product).to be_valid
  end
end
