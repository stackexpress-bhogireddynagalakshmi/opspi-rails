require 'rails_helper'

describe InvoiceManager::InvoiceAutoDebiter do
  subject { described_class.new(invoice) }

    let(:store_admin) { create(:spree_user,:with_store_admin_role,password: 'opspi@123') }

    let(:reseller_store) {
      create(:spree_store,url: 'reseller1.example.com', admin_email: store_admin.email)
    }
    let(:product) { create(:product,account: reseller_store.account)}
    let(:subscription) {create(:subscription,user: store_admin,plan:product)}

    let(:invoice) { nil }
    let(:admin_store) {create(:spree_store,url: 'example.com')}
    let!(:credit_card_payment_method) { create(:simple_credit_card_payment_method, display_on: 'both', stores: [reseller_store]) }


    describe '#call' do
      context 'when invoice is nil it will simply return nil' do
        it { expect(subject.call).to eq(nil)   }
      end     
     
      context 'return nil when invoice is in processing state  ' do
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'processing')}
          it { expect(subject.call).to eq(nil)   }
      end

      context 'return nil when invoice is in closed state ' do
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'closed')}
          it { expect(subject.call).to eq(nil)   }
      end

      context 'return nil when user do not have any default payment source ' do
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'active')}
          it do 
            expect(store_admin.payment_sources.count).to eq(0)
            expect(subject.call).to eq(nil) 
          end
      end

      context 'Attempt to charge when user do not have any default payment source ' do
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'processing')}
          it do 
          
          end
      end

    end
end
