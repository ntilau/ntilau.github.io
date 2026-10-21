# Isoko.app Local Backend

This is a local backend server for the Isoko.app e-commerce frontend. It provides mock API endpoints that match the ones used by the frontend.

## Endpoints Implemented

- `POST /register` - User registration
- `POST /login` - User login
- `GET /users/:token` - Get user data by token
- `GET /electronics/:category` - Get electronics products by category
- `GET /` - Health check

## Setup Instructions

### Prerequisites

- Node.js (v14 or higher)
- MongoDB (optional - the server will work with mock data even without MongoDB)

### Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

### Running the Server

#### Development Mode (with auto-restart):
```bash
npm run dev
```

#### Production Mode:
```bash
npm start
```

The server will start on port 5000 by default (http://localhost:5000).

### Environment Variables

You can customize the following by creating a `.env` file:

- `PORT` - Port to run the server on (default: 5000)
- `MONGODB_URI` - MongoDB connection string (default: mongodb://localhost:27017/isoko)
- `JWT_SECRET` - Secret for JWT tokens (default: isoko_secret_key_2026)

### API Usage

The frontend expects the backend to be available at `https://alibaba-backend.herokuapp.com`. To use this local backend with the frontend, you have two options:

#### Option 1: Modify the frontend code
Change all instances of `https://alibaba-backend.herokuapp.com` to `http://localhost:5000` in the HTML and JS files.

#### Option 2: Use a proxy
Set up a proxy to forward requests from `https://alibaba-backend.herokuapp.com` to your local server.

### Data Models

#### User
- email (string, required, unique)
- password (string, required, hashed)
- firstName (string, required)
- lastName (string, required)
- companyName (string)
- telNo (string)
- country (string, default: "India")
- tradeRole (string, enum: ["Buyer", "Seller", "Both"], default: "Buyer")

#### Product
- id (number, required)
- productTitle (string, required)
- price (number, required)
- qty (number, required)
- productImg (array of strings)

### Notes

- This backend uses JWT for authentication. Tokens are valid for 1 hour.
- Passwords are hashed using bcrypt.
- The electronics endpoint currently returns mock data. You can extend it to fetch from a real database.
- CORS is enabled to allow requests from any origin (adjust for production as needed).

### Troubleshooting

1. **MongoDB connection issues**: If you don't have MongoDB installed locally, the server will still work for authentication endpoints but product data will be mock data only.

2. **Port already in use**: Change the PORT in your .env file or kill the process using port 5000.

3. **CORS issues**: The server includes CORS middleware that allows all origins. For production, you may want to restrict this to specific domains.

## Database Setup (Optional)

If you want to use a real MongoDB database:

1. Install MongoDB locally or use a cloud service like MongoDB Atlas
2. Update the connection string in the `.env` file or in `server.js`
3. The server will automatically create the collections when you first register a user or add products

## Extending the Backend

You can extend this backend by:

1. Adding more product categories (apparel, car parts, etc.)
2. Implementing a shopping cart feature
3. Adding order processing endpoints
4. Adding admin endpoints for managing products and users
5. Connecting to a real database for persistent storage