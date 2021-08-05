require 'rails_helper'

  describe CustomStoreFinder do
    subject { described_class.new(scope: scope, url: url).execute }

    let!(:store) { create(:spree_store, default: true,url: 'lvh.me') }
    let!(:store_2) { create(:spree_store, url: 'another.com', default_currency: 'GBP') }

    let(:scope) { nil }
    let(:url) { nil }

    context 'no arguments' do

      it {
        expect(subject.id).to eq(nil) 
      }
    end

    context 'existing admin store' do
      let(:url) { 'lvh.me' }

      it do
         expect(subject).to eq(TenantManager::TenantHelper.admin_tenant&.spree_store) 
         expect(subject.url).to eq('lvh.me')
      end
    end

    context 'existing store' do
      let(:url) { 'another.com' }
      it {
         expect(subject).to eq(store_2) 
     }
    end

    context 'non-existing store' do
      let(:url) { 'something-different.com' }
       
      it {
        expect(subject.id).to eq(nil) 
      }
    end

    context 'with scope' do
      let(:scope) { Spree::Store.where(default_currency: 'GBP') }
      let(:url) { 'another.com' }

      it { expect(subject).to eq(store_2) }
    end
   end
