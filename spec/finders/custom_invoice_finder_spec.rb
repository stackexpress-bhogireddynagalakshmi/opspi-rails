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

    it {
      expect(subject).to eq(nil) 
    }
  end


  context 'by invoice number' do
    let(:subscription) {create(:subscription,user: store_admin)}

    let(:invoice) {  create(:invoice,account_id: reseller_store.account.id,user: store_admin,subscription: subscription)}
    
    it { expect(subject).to eq(invoice.invoice_number) }
  end




end
