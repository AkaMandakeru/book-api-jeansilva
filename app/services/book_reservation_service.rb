class BookReservationService
  class BookAlreadyReservedError < StandardError; end
  class ReservedByRequiredError < StandardError; end

  def initialize(book)
    @book = book
  end

  def reserve(reserved_by)
    validate_reservation!(reserved_by)

    @book.update!(status: :reserved, reserved_by: reserved_by)

    { success: true, message: "Book reserved successfully" }
  rescue BookAlreadyReservedError
    { success: false, message: "Book already reserved", error: :already_reserved }
  rescue ReservedByRequiredError
    { success: false, message: "Reserved by is required", error: :reserved_by_required }
  end

  private

  def validate_reservation!(reserved_by)
    raise BookAlreadyReservedError if @book.reserved?
    raise ReservedByRequiredError if reserved_by.blank?
  end
end
