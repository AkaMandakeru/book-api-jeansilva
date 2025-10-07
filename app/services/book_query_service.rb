class BookQueryService
  PER_PAGE = 5

  def initialize(filter: nil, page: nil)
    @filter = filter
    @page = page
  end

  def call
    {
      data: paginated_books,
      pagination: pagination_metadata
    }
  end

  private

  def paginated_books
    filtered_books.paginate(page: @page, per_page: PER_PAGE)
  end

  def filtered_books
    case @filter
    when 'reserved'
      Book.reserved
    when 'available'
      Book.available
    else
      Book.all
    end
  end

  def pagination_metadata
    {
      total: total_count,
      page: @page,
      per_page: PER_PAGE
    }
  end

  def total_count
    case @filter
    when 'reserved'
      Book.reserved.count
    when 'available'
      Book.available.count
    else
      Book.count
    end
  end
end
