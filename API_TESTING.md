# API Testing Guide

This document provides example payloads and curl commands for manually testing the Blog API endpoints.

## Authentication

### Sign Up
```bash
curl -X POST http://localhost:3000/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "Test User",
      "email": "test@example.com",
      "password": "password123",
      "image": "https://example.com/avatar.jpg"
    }
  }'
```

Note: The signup payload requires:
- `name` (required)
- `email` (required, must be valid email format, must be unique)
- `password` (required, minimum 6 characters)
- `image` (required)

### Login
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Save the returned token for subsequent requests:
```bash
export TOKEN="your_jwt_token_here"
```

## Posts

### Create Post
```bash
curl -X POST http://localhost:3000/api/v1/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "post": {
      "title": "My First Blog Post",
      "body": "This is the content of my first blog post.",
      "tag_list": "ruby, rails, api"
    }
  }'
```

Note: The post payload requires:
- `title` (required, maximum 255 characters)
- `body` (required)
- `tag_list` (required, at least one tag)

### List Posts
```bash
curl -X GET http://localhost:3000/api/v1/posts \
  -H "Authorization: Bearer $TOKEN"
```

### Get Single Post
```bash
curl -X GET http://localhost:3000/api/v1/posts/1 \
  -H "Authorization: Bearer $TOKEN"
```

### Update Post
```bash
curl -X PUT http://localhost:3000/api/v1/posts/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "post": {
      "title": "Updated Blog Post Title",
      "body": "Updated content of the blog post.",
      "tag_list": "ruby, rails, api, updated"
    }
  }'
```

Note: Posts are automatically scheduled for deletion after 24 hours.

### Delete Post
```bash
curl -X DELETE http://localhost:3000/api/v1/posts/1 \
  -H "Authorization: Bearer $TOKEN"
```

## Comments

### Create Comment
```bash
curl -X POST http://localhost:3000/api/v1/posts/1/comments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "comment": {
      "content": "This is a great post!"
    }
  }'
```

Note: The comment payload requires:
- `content` (required)

### List Comments
```bash
curl -X GET http://localhost:3000/api/v1/posts/1/comments \
  -H "Authorization: Bearer $TOKEN"
```

### Update Comment
```bash
curl -X PUT http://localhost:3000/api/v1/posts/1/comments/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "comment": {
      "content": "Updated comment content"
    }
  }'
```

Note: Only the comment author can update their comments.

### Delete Comment
```bash
curl -X DELETE http://localhost:3000/api/v1/posts/1/comments/1 \
  -H "Authorization: Bearer $TOKEN"
```

Note: Only the comment author can delete their comments.

## Tags

### Create Tag
```bash
curl -X POST http://localhost:3000/api/v1/tags \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "tag": {
      "name": "new-tag"
    }
  }'
```

Note: The tag payload requires:
- `name` (required, must be unique, will be converted to lowercase)

### List Tags
```bash
curl -X GET http://localhost:3000/api/v1/tags \
  -H "Authorization: Bearer $TOKEN"
```

### Remove Tag from Post
```bash
curl -X DELETE http://localhost:3000/api/v1/posts/1/tags/1 \
  -H "Authorization: Bearer $TOKEN"
```

Note: Only the post author can remove tags from their posts.

## Health Check

### Check API Health
```bash
curl -X GET http://localhost:3000/up
```

## Testing Tips

1. Always start with authentication to get a valid JWT token
2. Use the token in the Authorization header for all authenticated requests
3. Save the IDs returned from create operations to use in subsequent requests
4. Use the `-v` flag with curl for verbose output to see headers and response details
5. For Windows PowerShell, replace the single quotes with double quotes and escape the inner double quotes
6. Note that posts are automatically deleted after 24 hours
7. Tags are automatically converted to lowercase
8. Only post authors can modify their posts and comments
9. All requests except health check require authentication

Example with verbose output:
```bash
curl -v -X GET http://localhost:3000/api/v1/posts \
  -H "Authorization: Bearer $TOKEN"
```

## Postman Setup Guide

### Authentication Workflow

1. **Sign Up (if needed):**
   - Method: `POST`
   - URL: `http://localhost:3000/api/v1/auth/signup`
   - Headers: `Content-Type: application/json`
   - Body (raw JSON):
   ```json
   {
     "user": {
       "name": "Test User",
       "email": "test@example.com",
       "password": "password123",
       "image": "https://example.com/avatar.jpg"
     }
   }
   ```

2. **Login:**
   - Method: `POST`
   - URL: `http://localhost:3000/api/v1/auth/login`
   - Headers: `Content-Type: application/json`
   - Body (raw JSON):
   ```json
   {
     "email": "test@example.com",
     "password": "password123"
   }
   ```

3. **Copy the JWT token from the login response**

4. **For authenticated requests, use one of these methods:**

   **Method A - Authorization Tab (Recommended):**
   - Go to the **Authorization** tab
   - Type: Select "Bearer Token"
   - Token: Paste your JWT token (without "Bearer" prefix)

   **Method B - Headers Tab:**
   - Go to the **Headers** tab
   - Key: `Authorization`
   - Value: `Bearer YOUR_JWT_TOKEN_HERE`
   - **Important:** Include the space between "Bearer" and the token

### Troubleshooting Unauthorized Errors

If you get `401 Unauthorized` errors:

1. **Verify token format:** Ensure your Authorization header is exactly:
   ```
   Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo1Mn0.xCNXP4Q0gTlCjtSlIooF426TOai-6l4ryl7jTpKfWRU
   ```

2. **Check for extra spaces:** Copy the token carefully without extra spaces

3. **Test health check first:** Try `GET http://localhost:3000/up` (no auth required)

4. **Re-login if needed:** JWT tokens don't expire in this API, but if issues persist, try logging in again

5. **Check API logs:** Run `docker compose logs -f web` to see server-side errors

### Environment Variables in Postman

Create a Postman environment with:
- `baseUrl`: `http://localhost:3000`
- `token`: Your JWT token from login

Then use:
- URL: `{{baseUrl}}/api/v1/posts`
- Authorization: Bearer Token with `{{token}}`

## Common Response Codes

- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden (e.g., trying to modify someone else's post/comment)
- 404: Not Found
- 422: Unprocessable Entity (validation errors)
- 500: Internal Server Error

## Validation Error Examples

### Invalid User Signup
```json
{
  "errors": {
    "name": ["can't be blank"],
    "email": ["is invalid", "has already been taken"],
    "password": ["is too short (minimum is 6 characters)"],
    "image": ["can't be blank"]
  }
}
```

### Invalid Post Creation
```json
{
  "errors": {
    "title": ["can't be blank", "is too long (maximum is 255 characters)"],
    "body": ["can't be blank"],
    "tags": ["must have at least one tag"]
  }
}
```

### Invalid Comment Creation
```json
{
  "errors": {
    "content": ["can't be blank"]
  }
}
```

### Invalid Tag Creation
```json
{
  "errors": {
    "name": ["can't be blank", "has already been taken"]
  }
}
```
