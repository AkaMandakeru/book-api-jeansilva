class BooksController < ApplicationController
  before_action :load_book, only: [:show, :reserve]

  def index
    result = BookQueryService.new(
      filter: params[:filter],
      page: params[:page]
    ).call

    render json: result
  end

  def show
  end

  def reserve
    result = BookReservationService.new(@book).reserve(params[:reserved_by])

    if result[:success]
      render json: { message: result[:message] }
    else
      render json: { message: result[:message] }, status: :unprocessable_content
    end
  end

  private

  def load_book
    @book = Book.find(params[:id])
  end
end
