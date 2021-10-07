require 'rails_helper'

describe InvoiceManager::InvoiceAutoDebiter do
  subject { described_class.new(invoice) }


    #Super Admin Store
 
    let(:admin_user) { create(:spree_user,:with_super_admin_role,password: 'opspi@123') }
    let(:admin_store) {create(:spree_store,url: 'example.com')}
    

    let!(:store_admin) { create(:spree_user,:with_store_admin_role,password: 'opspi@123') }
    let!(:reseller_store) { create(:spree_store,url: 'reseller10.example.com', admin_email: store_admin.email,name: "Reseller Store") }
    let(:account) {admin_store.account}

    let(:product) { create(:product,account: reseller_store.account)}
    let(:subscription) {create(:subscription,user: store_admin,plan:product)}

    let(:invoice) { nil }
   
    let!(:credit_card_payment_method) { create(:simple_credit_card_payment_method, display_on: 'both', stores: [admin_store,reseller_store]) }

    before(:each) do
      reseller_store.account
    end
    describe '#call' do
      context 'when invoice is nil it will simply return nil' do
        it {  expect(subject.call).to eq(nil)   }
      end     
     
      context 'return nil when invoice is in processing state  ' do
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'processing',account_id: reseller_store.account.id)}
        
          it { expect(subject.call).to eq(nil)   }
      end

      context 'return nil when invoice is in closed state ' do
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'closed',account: reseller_store.account)}
          it { expect(subject.call).to eq(nil)   }
      end

      context 'return nil when user do not have any default payment source ' do
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'active',account: reseller_store.account)}
          it do 
            expect(store_admin.payment_sources.count).to eq(0)
            expect(subject.call).to eq(nil) 
          end
      end

      context 'Attempt to charge when user have default credit card but no payment profile on payment gateway ' do
       
        let(:credit_card) { create(:credit_card,default: true,user: store_admin,payment_method: credit_card_payment_method)}
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'active',account: reseller_store.account)}

        before  do
          store_admin.credit_cards << credit_card
        end

        it do 
          expect(credit_card.respond_to?(:track_data)).to be true
          expect(store_admin.default_credit_card.present?).to eq(true)
          expect(store_admin.default_credit_card.payment_method.present?).to eq(true)
          expect(store_admin.default_credit_card.payment_method.id).to eq(credit_card_payment_method.id)
          expect(subject.call).to eq(nil)
        end

      end


      context 'Attempt to charge when user have default credit card when having payment profile on payment gateway ' do
        
        let(:credit_card) { create(:credit_card,default: true,user: store_admin,payment_method: credit_card_payment_method)}
        let(:invoice) { create(:invoice, subscription: subscription, user: store_admin,status: 'active')}
        let(:order) { create(:completed_order_with_totals, store: admin_store,account: admin_store.account,user: store_admin) }
        
        let!(:payment) do
          create(
            :payment,
            order: order,
            amount: order.total,
            state: 'completed',
            source: credit_card,
            payment_method_id: credit_card.payment_method_id
          )
        end

        before do
          store_admin.credit_cards << credit_card
        end

     

      end

    end
end
