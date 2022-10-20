require 'rails_helper'

  describe CustomStoreFinder do
    subject { described_class.new(scope: scope, url: url).execute }

    let!(:store) { create(:spree_store, default: true,url: 'example.com') }
    let!(:store_2) { create(:spree_store, url: 'store2.example.com', default_currency: 'GBP') }

    let(:scope) { nil }
    let(:url) { nil }

    # context 'no arguments' do

    #   it {
    #     expect(subject&.id).to eq(nil) 
    #   }
    # end

    context 'existing admin store' do
      let(:url) { 'example.com' }

      it do
         expect(subject).to eq(TenantManager::TenantHelper.admin_tenant&.spree_store) 
         expect(subject.url).to eq('example.com')
      end
    end

    context 'existing store' do
      let(:url) { 'store2.example.com' }
      it {
         expect(subject).to eq(store_2) 
     }
    end

    # context 'non-existing store' do
    #   let(:url) { 'store3.example.com' }
       
    #   it {
    #     expect(subject&.id).to eq(nil) 
    #   }
    # end

    context 'with scope' do
      let(:scope) { Spree::Store.where(default_currency: 'GBP') }
      let(:url) { 'store2.example.com' }

      it { expect(subject).to eq(store_2) }
    end
   end
