require 'rails_helper'

RSpec.describe BookReservationService do
  describe '#reserve' do
    let(:service) { described_class.new(book) }

    context 'when book is available' do
      let(:book) { create(:book, status: :available) }

      context 'with valid reserved_by parameter' do
        it 'returns success result' do
          result = service.reserve('John Doe')

          expect(result[:success]).to be true
          expect(result[:message]).to eq('Book reserved successfully')
        end

        it 'reserves the book' do
          expect {
            service.reserve('John Doe')
          }.to change { book.reload.status }.from('available').to('reserved')
        end

        it 'sets the reserved_by field' do
          expect {
            service.reserve('John Doe')
          }.to change { book.reload.reserved_by }.from(nil).to('John Doe')
        end
      end

      context 'with blank reserved_by parameter' do
        it 'returns failure result with reserved_by_required error' do
          result = service.reserve('')

          expect(result[:success]).to be false
          expect(result[:message]).to eq('Reserved by is required')
          expect(result[:error]).to eq(:reserved_by_required)
        end

        it 'does not change book status' do
          expect {
            service.reserve('')
          }.not_to change { book.reload.status }
        end

        it 'does not set reserved_by field' do
          expect {
            service.reserve('')
          }.not_to change { book.reload.reserved_by }
        end
      end

      context 'with nil reserved_by parameter' do
        it 'returns failure result' do
          result = service.reserve(nil)

          expect(result[:success]).to be false
          expect(result[:message]).to eq('Reserved by is required')
          expect(result[:error]).to eq(:reserved_by_required)
        end

        it 'does not change book status' do
          expect {
            service.reserve(nil)
          }.not_to change { book.reload.status }
        end
      end
    end

    context 'when book is already reserved' do
      let(:book) { create(:book, status: :reserved, reserved_by: 'Jane Smith') }

      it 'returns failure result with already_reserved error' do
        result = service.reserve('John Doe')

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Book already reserved')
        expect(result[:error]).to eq(:already_reserved)
      end

      it 'does not change the reserved_by field' do
        expect {
          service.reserve('John Doe')
        }.not_to change { book.reload.reserved_by }
      end

      it 'keeps the book status as reserved' do
        expect {
          service.reserve('John Doe')
        }.not_to change { book.reload.status }
      end
    end
  end

  describe 'error classes' do
    it 'defines BookAlreadyReservedError' do
      expect(described_class::BookAlreadyReservedError).to be < StandardError
    end

    it 'defines ReservedByRequiredError' do
      expect(described_class::ReservedByRequiredError).to be < StandardError
    end
  end
end

