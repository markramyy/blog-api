# Blog API

A robust RESTful API for a blog application built with Ruby on Rails, using Docker for containerization. The API provides endpoints for user authentication, blog posts, comments, and tags management.

## Tech Stack

- Ruby on Rails 8.0
- PostgreSQL 16
- Redis 7
- Sidekiq for background job processing
- Docker & Docker Compose
- RSpec for testing

## Prerequisites

- Docker
- Docker Compose
- Git

## Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd blog-api
```

2. Create a `.env` file in the root directory with the following environment variables:
```env
# Database
POSTGRES_USER=blog_api
POSTGRES_PASSWORD=your_password
POSTGRES_DB=blog_api_development

# Redis
REDIS_URL=redis://redis:6379/1

# Sidekiq
SIDEKIQ_USERNAME=admin
SIDEKIQ_PASSWORD=your_secure_password

# Rails
RAILS_ENV=development
RAILS_MAX_THREADS=5
```

3. Build and start the containers:
```bash
docker compose up --build
```

This will start the following services:
- Web server (Rails) on port 3000
- PostgreSQL on port 5432
- Redis on port 6379
- Sidekiq for background jobs
- Sidekiq web interface (accessible at http://localhost:3000/sidekiq)

## Running Tests

To run the test suite:

```bash
docker compose run test
```

## API Endpoints

For detailed API testing instructions, example payloads, and curl commands, please refer to [API_TESTING.md](API_TESTING.md). The following is a quick reference of available endpoints:

### Authentication

- `POST /api/v1/auth/signup` - Register a new user
- `POST /api/v1/auth/login` - Login and get authentication token

### Posts

- `GET /api/v1/posts` - List all posts
- `GET /api/v1/posts/:id` - Get a specific post
- `POST /api/v1/posts` - Create a new post
- `PUT /api/v1/posts/:id` - Update a post
- `DELETE /api/v1/posts/:id` - Delete a post

### Comments

- `GET /api/v1/posts/:post_id/comments` - List comments for a post
- `POST /api/v1/posts/:post_id/comments` - Create a comment on a post
- `PUT /api/v1/posts/:post_id/comments/:id` - Update a comment
- `DELETE /api/v1/posts/:post_id/comments/:id` - Delete a comment

### Tags

- `GET /api/v1/tags` - List all tags
- `POST /api/v1/tags` - Create a new tag
- `DELETE /api/v1/posts/:post_id/tags/:id` - Remove a tag from a post

### Health Check

- `GET /up` - Health check endpoint

## Development

The application uses Docker for development, which means you don't need to install Ruby, PostgreSQL, or Redis locally. All services are containerized and managed through Docker Compose.

### Useful Commands

- Start the application: `docker compose up`
- Stop the application: `docker compose down`
- View logs: `docker compose logs -f`
- Run Rails console: `docker compose run web rails console`
- Run database migrations: `docker compose run web rails db:migrate`
- Run database seeds: `docker compose run web rails db:seed`

## Production Deployment

The application is configured for production deployment with the following considerations:
- SSL/TLS enabled
- Production-grade database configuration
- Sidekiq for background job processing
- Redis for caching and job queues
- Proper security headers and CORS configuration

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
