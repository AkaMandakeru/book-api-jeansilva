require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      book = build(:book)
      expect(book).to be_valid
    end
  end

  describe 'database columns' do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:author).of_type(:string).with_options(null: false) }
    it { should have_db_column(:status).of_type(:integer) }
    it { should have_db_column(:reserved_by).of_type(:string) }
    it { should have_db_column(:published_at).of_type(:date) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(available: 0, reserved: 1) }

    it 'defaults to available status' do
      book = Book.create(title: 'Test Book', author: 'Test Author')
      expect(book.status).to eq('available')
      expect(book).to be_available
    end

    it 'can be set to reserved' do
      book = create(:book, status: :reserved)
      expect(book.status).to eq('reserved')
      expect(book).to be_reserved
    end
  end

  describe 'status methods' do
    let(:available_book) { create(:book, status: :available) }
    let(:reserved_book) { create(:book, status: :reserved, reserved_by: 'John Doe') }

    context 'when book is available' do
      it 'returns true for available?' do
        expect(available_book.available?).to be true
      end

      it 'returns false for reserved?' do
        expect(available_book.reserved?).to be false
      end

      it 'does not have a reserved_by value' do
        expect(available_book.reserved_by).to be_nil
      end
    end

    context 'when book is reserved' do
      it 'returns false for available?' do
        expect(reserved_book.available?).to be false
      end

      it 'returns true for reserved?' do
        expect(reserved_book.reserved?).to be true
      end

      it 'has a reserved_by value' do
        expect(reserved_book.reserved_by).to eq('John Doe')
      end
    end
  end

  describe 'scopes' do
    let!(:available_books) { create_list(:book, 3, status: :available) }
    let!(:reserved_books) { create_list(:book, 2, status: :reserved, reserved_by: 'Test User') }

    it 'filters available books' do
      expect(Book.available.count).to eq(3)
      expect(Book.available).to match_array(available_books)
    end

    it 'filters reserved books' do
      expect(Book.reserved.count).to eq(2)
      expect(Book.reserved).to match_array(reserved_books)
    end
  end

  describe 'attribute changes' do
    let(:book) { create(:book, status: :available) }

    it 'can change from available to reserved' do
      expect {
        book.update(status: :reserved, reserved_by: 'Jane Doe')
      }.to change { book.status }.from('available').to('reserved')
    end

    it 'can update reserved_by when reserving' do
      expect {
        book.update(status: :reserved, reserved_by: 'Jane Doe')
      }.to change { book.reserved_by }.from(nil).to('Jane Doe')
    end

    it 'can change from reserved to available' do
      reserved_book = create(:book, status: :reserved, reserved_by: 'John Doe')

      expect {
        reserved_book.update(status: :available, reserved_by: nil)
      }.to change { reserved_book.status }.from('reserved').to('available')
    end
  end

  describe 'timestamps' do
    let(:book) { create(:book) }

    it 'sets created_at on creation' do
      expect(book.created_at).to be_present
      expect(book.created_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'sets updated_at on creation' do
      expect(book.updated_at).to be_present
      expect(book.updated_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'updates updated_at when record changes' do
      original_updated_at = book.updated_at
      sleep 0.01 # Ensure time difference

      book.update(title: 'Updated Title')
      expect(book.updated_at).to be > original_updated_at
    end
  end

  describe 'data integrity' do
    it 'creates a book with all attributes' do
      book = Book.create(
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        published_at: Date.new(1925, 4, 10),
        status: :available
      )

      expect(book).to be_persisted
      expect(book.title).to eq('The Great Gatsby')
      expect(book.author).to eq('F. Scott Fitzgerald')
      expect(book.published_at).to eq(Date.new(1925, 4, 10))
      expect(book.status).to eq('available')
    end

    it 'allows published_at to be nil' do
      book = create(:book, published_at: nil)
      expect(book.published_at).to be_nil
      expect(book).to be_valid
    end

    it 'allows reserved_by to be nil for available books' do
      book = create(:book, status: :available, reserved_by: nil)
      expect(book.reserved_by).to be_nil
      expect(book).to be_valid
    end
  end
end
