require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  describe "GET #index" do
    let!(:available_books) { create_list(:book, 3, status: :available) }
    let!(:reserved_books) { create_list(:book, 2, status: :reserved) }

    context "without filter" do
      it "returns all books with pagination" do
        get :index
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
        expect(json_response['pagination']).to be_present
        expect(json_response['pagination']['total']).to eq(5)
        expect(json_response['pagination']['per_page']).to eq(5)
      end

      it "paginates results correctly" do
        create_list(:book, 8, status: :available)

        get :index, params: { page: 1 }
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(5)
        expect(json_response['pagination']['page']).to eq("1")

        get :index, params: { page: 2 }
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(5)
      end
    end

    context "with filter='reserved'" do
      it "returns only reserved books" do
        get :index, params: { filter: 'reserved' }
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(2)
        json_response['data'].each do |book|
          expect(book['status']).to eq('reserved')
        end
      end

      it "paginates reserved books correctly" do
        create_list(:book, 6, status: :reserved)

        get :index, params: { filter: 'reserved', page: 1 }
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(5)
      end
    end

    context "with filter='available'" do
      it "returns only available books" do
        get :index, params: { filter: 'available' }
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(3)
        json_response['data'].each do |book|
          expect(book['status']).to eq('available')
        end
      end

      it "paginates available books correctly" do
        create_list(:book, 6, status: :available)

        get :index, params: { filter: 'available', page: 1 }
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(5)
      end
    end
  end

  describe "GET #show" do
    let(:book) { create(:book, title: "Test Book", author: "Test Author") }

    context "when book exists" do
      it "returns http success" do
        get :show, params: { id: book.id }
        expect(response).to have_http_status(:success)
      end

      it "loads the correct book" do
        get :show, params: { id: book.id }
        expect(assigns(:book)).to eq(book)
      end
    end

    context "when book does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get :show, params: { id: 9999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #reserve" do
    let(:available_book) { create(:book, status: :available, title: "Available Book") }
    let(:reserved_book) { create(:book, status: :reserved, title: "Reserved Book", reserved_by: "John Doe") }

    context "when book is available" do
      context "with valid parameters" do
        it "reserves the book successfully" do
          post :reserve, params: { id: available_book.id, reserved_by: "Jane Smith" }

          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq("Book reserved successfully")

          available_book.reload
          expect(available_book.status).to eq('reserved')
          expect(available_book.reserved_by).to eq("Jane Smith")
        end

        it "updates the book status to reserved" do
          expect {
            post :reserve, params: { id: available_book.id, reserved_by: "Jane Smith" }
          }.to change { available_book.reload.status }.from('available').to('reserved')
        end

        it "updates the reserved_by field" do
          expect {
            post :reserve, params: { id: available_book.id, reserved_by: "Jane Smith" }
          }.to change { available_book.reload.reserved_by }.from(nil).to("Jane Smith")
        end
      end

      context "without reserved_by parameter" do
        it "returns unprocessable_content status" do
          post :reserve, params: { id: available_book.id }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns an error message" do
          post :reserve, params: { id: available_book.id }
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq("Reserved by is required")
        end

        it "does not change the book status" do
          expect {
            post :reserve, params: { id: available_book.id }
          }.not_to change { available_book.reload.status }
        end
      end

      context "with blank reserved_by parameter" do
        it "returns unprocessable_content status" do
          post :reserve, params: { id: available_book.id, reserved_by: "" }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns an error message" do
          post :reserve, params: { id: available_book.id, reserved_by: "" }
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq("Reserved by is required")
        end
      end
    end

    context "when book is already reserved" do
      it "returns unprocessable_content status" do
        post :reserve, params: { id: reserved_book.id, reserved_by: "Jane Smith" }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message" do
        post :reserve, params: { id: reserved_book.id, reserved_by: "Jane Smith" }
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("Book already reserved")
      end

      it "does not change the reserved_by field" do
        expect {
          post :reserve, params: { id: reserved_book.id, reserved_by: "Jane Smith" }
        }.not_to change { reserved_book.reload.reserved_by }
      end
    end

    context "when book does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          post :reserve, params: { id: 9999, reserved_by: "Jane Smith" }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "private methods" do
    describe "#load_book" do
      let(:book) { create(:book) }

      it "loads the book from params[:id]" do
        get :show, params: { id: book.id }
        expect(assigns(:book)).to eq(book)
      end

      it "is called before show action" do
        expect(controller).to receive(:load_book).and_call_original
        get :show, params: { id: book.id }
      end

      it "is called before reserve action" do
        expect(controller).to receive(:load_book).and_call_original
        post :reserve, params: { id: book.id, reserved_by: "Test User" }
      end
    end
  end
end

