# Book Management System API

A Ruby on Rails JSON API for managing books and reservations. This API allows you to list books with filtering and pagination, view individual book details, and reserve books.

## Features

- List books with filtering and pagination
- View individual book details
- Reserve available books
- Service-oriented architecture for maintainability
- Comprehensive test coverage (76 examples)

## Tech Stack

- **Ruby**: 3.2.5
- **Rails**: 8.0.3
- **Database**: PostgreSQL
- **Testing**: RSpec, FactoryBot, Faker
- **Pagination**: will_paginate

## Prerequisites

- Ruby 3.2.5 or higher
- PostgreSQL
- Bundler

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd books_api
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Database Setup

Create and migrate the database:

```bash
rails db:create
rails db:migrate
```

### 4. Seed the Database

Populate the database with sample data (creates 15 books):

```bash
rails db:seed
```

This will create 15 books with random titles, authors, and publication dates.

### 5. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

### 6. Run Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test suites
bundle exec rspec spec/controllers/
bundle exec rspec spec/models/
bundle exec rspec spec/services/

# Run with documentation format
bundle exec rspec --format documentation
```

## API Endpoints

### Base URL
```
http://localhost:3000
```

---

### 1. List Books

Get a paginated list of books with optional filtering.

**Endpoint:** `GET /books`

**Query Parameters:**

| Parameter | Type   | Required | Description                                    |
|-----------|--------|----------|------------------------------------------------|
| `filter`  | string | No       | Filter books by status: `available` or `reserved` |
| `page`    | integer| No       | Page number for pagination (default: 1)        |

**Response Format:**

```json
{
  "data": [
    {
      "id": 1,
      "title": "The Great Gatsby",
      "author": "F. Scott Fitzgerald",
      "published_at": "1925-04-10",
      "status": "available",
      "reserved_by": null,
      "created_at": "2025-10-07T12:00:00.000Z",
      "updated_at": "2025-10-07T12:00:00.000Z"
    }
  ],
  "pagination": {
    "total": 15,
    "page": "1",
    "per_page": 5
  }
}
```

**Examples:**

```bash
# Get all books (first page)
curl http://localhost:3000/books

# Get page 2
curl http://localhost:3000/books?page=2

# Get only available books
curl http://localhost:3000/books?filter=available

# Get only reserved books
curl http://localhost:3000/books?filter=reserved

# Get available books, page 2
curl http://localhost:3000/books?filter=available&page=2
```

**Notes:**
- Results are paginated with 5 books per page
- Without a filter, returns all books
- `status` can be either `"available"` or `"reserved"`
- `reserved_by` will be `null` for available books

---

### 2. Get Book Details

Get details of a specific book.

**Endpoint:** `GET /books/:id`

**URL Parameters:**

| Parameter | Type    | Required | Description           |
|-----------|---------|----------|-----------------------|
| `id`      | integer | Yes      | The ID of the book    |

**Response Format:**

```json
{
  "id": 1,
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "published_at": "1925-04-10",
  "status": "available",
  "reserved_by": null,
  "created_at": "2025-10-07T12:00:00.000Z",
  "updated_at": "2025-10-07T12:00:00.000Z"
}
```

**Examples:**

```bash
# Get book with ID 1
curl http://localhost:3000/books/1

# Get book with ID 5
curl http://localhost:3000/books/5
```

**Error Response (404):**

```json
{
  "error": "Record not found"
}
```

---

### 3. Reserve a Book

Reserve an available book.

**Endpoint:** `POST /books/:id/reserve`

**URL Parameters:**

| Parameter | Type    | Required | Description           |
|-----------|---------|----------|-----------------------|
| `id`      | integer | Yes      | The ID of the book    |

**Request Body:**

| Field         | Type   | Required | Description                    |
|---------------|--------|----------|--------------------------------|
| `reserved_by` | string | Yes      | Name or identifier of the person reserving |

**Request Example:**

```bash
curl -X POST http://localhost:3000/books/1/reserve \
  -H "Content-Type: application/json" \
  -d '{"reserved_by": "John Doe"}'
```

**Success Response (200):**

```json
{
  "message": "Book reserved successfully"
}
```

**Error Responses:**

**Book Already Reserved (422):**
```json
{
  "message": "Book already reserved"
}
```

**Missing reserved_by Parameter (422):**
```json
{
  "message": "Reserved by is required"
}
```

**Book Not Found (404):**
```json
{
  "error": "Record not found"
}
```

**Examples:**

```bash
# Reserve a book
curl -X POST http://localhost:3000/books/1/reserve \
  -H "Content-Type: application/json" \
  -d '{"reserved_by": "John Doe"}'

# Try to reserve with empty reserved_by (will fail)
curl -X POST http://localhost:3000/books/1/reserve \
  -H "Content-Type: application/json" \
  -d '{"reserved_by": ""}'

# Try to reserve an already reserved book (will fail)
curl -X POST http://localhost:3000/books/1/reserve \
  -H "Content-Type: application/json" \
  -d '{"reserved_by": "Jane Smith"}'
```

---

## Pagination Details

The API uses pagination for the book listing endpoint:

- **Items per page**: 5 books
- **Default page**: 1
- **Page parameter**: Use `?page=N` to specify page number

The pagination metadata includes:
- `total`: Total number of books (filtered or unfiltered)
- `page`: Current page number
- `per_page`: Number of items per page (always 5)

---

## Book Status Values

Books can have one of two statuses:

| Status      | Value | Description                            |
|-------------|-------|----------------------------------------|
| `available` | 0     | Book is available for reservation      |
| `reserved`  | 1     | Book is currently reserved by someone  |

---

## Architecture

The application follows a service-oriented architecture:

- **Controllers**: Handle HTTP requests and responses
- **Services**: Contain business logic
  - `BookQueryService`: Handles book filtering and pagination
  - `BookReservationService`: Handles book reservation logic
- **Models**: Handle data persistence and validation

---

## Testing

The application has comprehensive test coverage:

- **Controller Tests**: 24 examples
- **Model Tests**: 28 examples
- **Service Tests**: 24 examples
- **Total**: 76 examples, 0 failures

Run tests with:

```bash
bundle exec rspec
```

---

## Development

### Reset Database

To reset the database and reseed:

```bash
rails db:reset
```

This will drop the database, recreate it, run migrations, and load the seed data.

### Console

Access the Rails console:

```bash
rails console
```

### Database Console

Access the PostgreSQL console:

```bash
rails dbconsole
```

---

## Common Use Cases

### Example Workflow

1. **List all books to see what's available:**
   ```bash
   curl http://localhost:3000/books?filter=available
   ```

2. **View details of a specific book:**
   ```bash
   curl http://localhost:3000/books/1
   ```

3. **Reserve the book:**
   ```bash
   curl -X POST http://localhost:3000/books/1/reserve \
     -H "Content-Type: application/json" \
     -d '{"reserved_by": "John Doe"}'
   ```

4. **Verify the book is now reserved:**
   ```bash
   curl http://localhost:3000/books/1
   # Status will be "reserved" and reserved_by will be "John Doe"
   ```

5. **List all reserved books:**
   ```bash
   curl http://localhost:3000/books?filter=reserved
   ```

---

## Troubleshooting

### Port Already in Use

If port 3000 is already in use, start the server on a different port:

```bash
rails server -p 3001
```

### Database Connection Issues

Ensure PostgreSQL is running:

```bash
# macOS (with Homebrew)
brew services start postgresql

# Linux
sudo service postgresql start
```

### Reset the Database

If you encounter database issues:

```bash
rails db:drop db:create db:migrate db:seed
```

---

## License

This project is available as open source.

---

## Contact

For questions or issues, please open an issue in the repository.
