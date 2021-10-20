require 'rails_helper'

describe CustomInvoiceFinder do
  subject { described_class.new(scope: Invoice, invoice_number: invoice_number ,order_id: order_id).execute }

  #Super Admin Store
  let(:admin_user) { create(:spree_user,:with_super_admin_role,password: 'opspi@123') }
  let(:admin_store) {create(:spree_store,url: 'example.com')}
  
  #Reseller Store
  let(:store_admin) { create(:spree_user,:with_store_admin_role,password: 'opspi@123') }
  let(:reseller_store){create(:spree_store,url: 'reseller1.example.com',admin_email: store_admin.email)}

  let(:invoice_number) { nil }
  let(:order_id) { nil }


  context 'no arguments' do
    it {  expect(subject).to eq(nil)   }
  end

  context 'by invoice number' do
    before do 
      reseller_store
    end
    
   let(:product1) { create(:product,account: admin_store.account)}
   let(:subscription) { create(:subscription,user: store_admin,plan: product1)}
  
    let(:invoice) {  create(:invoice,account: reseller_store.account,user: store_admin,subscription: subscription)}
    let(:invoice_number) { invoice.invoice_number }

    # it do
    #   byebug
    #  expect(subject.invoice_number).to eq(invoice.invoice_number)
    # end

  end

end
