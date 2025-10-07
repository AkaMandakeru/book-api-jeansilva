require 'rails_helper'

RSpec.describe BookQueryService do
  describe '#call' do
    let!(:available_books) { create_list(:book, 3, status: :available) }
    let!(:reserved_books) { create_list(:book, 2, status: :reserved, reserved_by: 'Test User') }

    context 'without filter' do
      let(:service) { described_class.new }

      it 'returns all books' do
        result = service.call

        expect(result[:data].count).to eq(5)
      end

      it 'includes pagination metadata' do
        result = service.call

        expect(result[:pagination]).to be_present
        expect(result[:pagination][:total]).to eq(5)
        expect(result[:pagination][:per_page]).to eq(5)
      end

      it 'paginates results' do
        create_list(:book, 8, status: :available)

        result = service.call
        expect(result[:data].size).to eq(5)
        expect(result[:pagination][:total]).to eq(13)
      end
    end

    context 'with filter="available"' do
      let(:service) { described_class.new(filter: 'available') }

      it 'returns only available books' do
        result = service.call

        expect(result[:data].count).to eq(3)
        result[:data].each do |book|
          expect(book.status).to eq('available')
        end
      end

      it 'includes correct pagination total' do
        result = service.call

        expect(result[:pagination][:total]).to eq(3)
      end
    end

    context 'with filter="reserved"' do
      let(:service) { described_class.new(filter: 'reserved') }

      it 'returns only reserved books' do
        result = service.call

        expect(result[:data].count).to eq(2)
        result[:data].each do |book|
          expect(book.status).to eq('reserved')
        end
      end

      it 'includes correct pagination total' do
        result = service.call

        expect(result[:pagination][:total]).to eq(2)
      end
    end

    context 'with page parameter' do
      let(:service) { described_class.new(page: 2) }

      before do
        create_list(:book, 8, status: :available)
      end

      it 'returns the correct page of results' do
        result = service.call

        expect(result[:pagination][:page]).to eq(2)
        expect(result[:data].size).to eq(5)
      end

      it 'includes page in pagination metadata' do
        result = service.call

        expect(result[:pagination][:page]).to eq(2)
      end
    end

    context 'with both filter and page parameters' do
      let(:service) { described_class.new(filter: 'available', page: 1) }

      before do
        create_list(:book, 10, status: :available)
      end

      it 'applies both filter and pagination' do
        result = service.call

        expect(result[:data].size).to eq(5)
        result[:data].each do |book|
          expect(book.status).to eq('available')
        end
        expect(result[:pagination][:page]).to eq(1)
      end
    end
  end

  describe 'PER_PAGE constant' do
    it 'is set to 5' do
      expect(described_class::PER_PAGE).to eq(5)
    end
  end
end

