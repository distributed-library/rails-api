class Book

  RESULTS_PER_PAGE = 10
  ORDER_BY = 'relevance'
  # params
  # args[:isbn]:String => book isbn number which is to be searched on google books
  # args[:title]:String => book title which is to be searched on google books 
  def initialize(args)
    @isbn = args[:isbn] 
    @title = args[:title]
  end

  def search
    return search_results 
  end

  private

  def search_results
    books = search_by_isbn 
    if (books.nil? || no_items?(books)) && @title.present?
      books = search_by_title
      return nil if no_items?(books)
    end
    return books.collect{|book| book_details(book: book) }
  end

  def no_items?(books)
    books.total_items == 0
  end

  def search_by_isbn
    return nil if @isbn.nil?
    query = "isbn:#{@isbn}"
    find_books(query: query)
  end

  def search_by_title
    query = "intitle:#{@title}"
    find_books(query: query)
  end

  def find_books(query: nil)
    GoogleBooks.search(query, { count: RESULTS_PER_PAGE, order_by: ORDER_BY })
  end

  def book_details(book: nil)
    {
      uid: book.id,
      isbn: book.isbn,
      title: book.title,
      authors: book.authors,
      image: book.image_link,
      publisher: book.publisher,
      publisher_date: book.published_date,
      description: book.description,
      categories: book.categories,
      language: book.language,
      rating: book.average_rating
    }
  end
end