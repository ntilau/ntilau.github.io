# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Isoko.app is a frontend-only static e-commerce site with a dual data-flow architecture:

1. **Electronics Track** (electronics.html, electronics-subcategory.html, openproduct.html, shoppingcart.html, index.html, signin.html, signUp.html):
   - Consumes a REST API from the local backend (included in the repository) for authentication and product data
   - Auth endpoints: POST /register, POST /login, GET /users/{token}
   - Product endpoint: GET /electronics/{category} (returns mock data)
   - Uses localStorage for token (`Authorization`), cart (`alibabacart`), opened product (`openedProduct`), category (`category`)

2. **Apparels/Car Parts Track** (apparels.html, apparel.html, carpart.html):
   - Uses **static, hardcoded product arrays** defined directly in the HTML files
   - No backend API calls; all product data is client-side
   - Product detail flow uses localStorage (`details_prod` for apparels, `openedProduct` for carparts via shared openproduct.js)
   - Shares auth/cart mechanisms with electronics track via common navbar.js and localStorage keys

The repository includes a local backend (`backend/`) for development, allowing full functionality without external dependencies.

## Project Structure

```
Isoko/
├── [HTML pages for both tracks]
├── components/          # Shared UI components (ES modules)
│   ├── navbar.js        # Navigation bar (auth-aware, cart count)
│   ├── footer.js        # Footer
│   └── homepagefooter.js# Homepage-specific footer
├── script/              # Page-specific JavaScript
│   ├── apparel.js       # Apparel product detail logic
│   ├── carpart.js       # Car parts logic (static array)
│   ├── electronics.js   # Electronics product fetching/display
│   ├── openproduct.js   # Product detail logic (shared)
│   └── shoppingcart.js  # Shopping cart logic
├── style/               # CSS stylesheets (page-specific and component)
├── backend/             # Local development server (Node.js/Express)
│   ├── server.js        # API implementation + mock data
│   └── package.json
└── footerImg/           # Image assets for footer
```

## Development Setup

### Prerequisites
- Modern web browser
- Node.js (v14 or higher) - for local backend
- Python (for simple frontend server) OR Apache2 (optional)

### Running the Local Backend (Required for Electronics Track)

```bash
# Navigate to backend directory
cd backend

# Install dependencies (first time only)
npm install

# Start the server
npm run dev  # Uses nodemon for auto-restart during development
# OR
npm start    # Standard Node.js mode

# The backend will run on http://localhost:5003 by default
# (Port configurable via the PORT environment variable)
```

### Running the Frontend

#### Option 1: Python Built-in Server (Recommended for Development)
```bash
# From repository root
python -m http.server 8080

# Access the site at http://localhost:8080
```

#### Option 2: Apache2 (Production-like)
```bash
# Copy files to Apache document root (adjust path as needed)
sudo cp -r * /var/www/html/

# Ensure proper permissions
sudo chown -R www-data:www-data /var/www/html/

# Access the site at http://localhost/
```

### Backend URL

The API base URL is hardcoded in the electronics-track HTML pages and `script/electronics.js`. It currently points at `http://143.47.179.233:5003`; change those occurrences directly to use a different backend.

## Common Development Tasks

### Editing Pages
1. Modify HTML files in the root directory for structure/content
2. Update corresponding CSS files in the `style/` directory
3. Update JavaScript files in the `script/` directory for page-specific logic
4. Update component files in the `components/` directory for shared UI elements

### Working with Components
- **navbar.js**: Handles navigation bar functionality including responsive menu, auth-greeting (Hi, {firstName}), signout button, and cart count display
- **footer.js**: Manages footer content and social media links
- **homepagefooter.js**: Controls homepage-specific footer elements

Components are imported as ES modules in `<script type="module">` blocks on each page that uses them.

### Styling
- CSS follows a pattern: `[page-name].css` for page-specific styles
- Component-specific styles: `navbar.css`, `footer.css`, `homepagefooter.css`
- Global/scattered styles: `Mymarket.css`, `fromnewarrivals.css`, etc.

### JavaScript Patterns
- Uses vanilla JS with `fetch()` API for HTTP requests (electronics track only)
- Authentication tokens stored in `localStorage` under key `Authorization` (JWT token)
- Cart stored in `localStorage` under key `alibabacart`
- Product detail flow: 
  - Electronics: click sets `localStorage.openedProduct` → `openproduct.html`
  - Apparels: click sets `localStorage.details_prod` → `apparel.html`
  - Car Parts: click sets `localStorage.openedProduct` → `openproduct.html` (shared)
- Event listeners attached using `addEventListener` or inline `onclick` attributes

## Local Backend Details (`backend/server.js`)

### Endpoints
- `POST /register` - User registration (bcrypt-hashed passwords)
- `POST /login` - Returns JWT token and user data (excludes password)
- `GET /users/{token}` - Auth middleware + returns user data (requires valid token)
- `GET /electronics/{category}` - Returns mock electronics products (same 3 items for any category)
- `GET /` - Health check

### Features
- In-memory storage for users (Map); all data resets when the server restarts
- JWT authentication with secret `isoko_secret_key_2026`, 1-hour expiry
- CORS enabled for all origins (adjust for production as needed)
- Port configurable via `PORT` environment variable (defaults to 5003)

### Data Models (Mock)
- **User**: id, email, password (hashed), firstName, lastName, companyName, telNo, country, tradeRole
- **Product**: id, productTitle, price, qty, productImg (array of image URLs)

### Setup Notes
- Users are stored in an in-memory Map; there is no database layer
- Passwords are hashed using bcrypt
- The electronics endpoint returns mock data; extend to fetch from real database as needed

## Important Notes

### Dual Data Flow
- **Electronics pages** depend on the backend API for product data and authentication
- **Apparels/Car Parts pages** are completely self-contained with static product arrays
- Both tracks share the same authentication and cart mechanisms via localStorage
- The navbar component (`navbar.js`) is shared and appears on all pages, showing auth state and cart count

### Authentication Flow
1. User registers/logs in via `/register` or `/login` endpoints
2. Backend returns JWT token
3. Frontend stores token in `localStorage.Authorization` (as JSON-stringified value)
4. On subsequent page loads, token is checked; if present:
   - Fetch user data from `/users/{token}`
   - Update navbar to show "Hi, {firstName}" and signout button
   - Display cart count if `alibabacart` has items

### File Relationships
- HTML files reference CSS via `<link>` tags in `<head>`
- HTML files reference JavaScript via `<script>` tags before closing `</body>`
- Component JavaScript files are imported via ES modules in `<script type="module">` blocks
- All API calls (electronics track only) use the same hardcoded backend URL

### Troubleshooting
- If electronics features don't work, verify backend is running and frontend is pointing to correct URL
- Check browser console for JavaScript errors
- Network tab in dev tools shows API call successes/failures
- Ensure localStorage keys are set correctly (token, cart, etc.)
- For Apache2 deployment, ensure .htaccess or server config allows client-side routing

## Deployment

The frontend can be deployed to any static file hosting service (Netlify, Vercel, GitHub Pages, AWS S3, etc.) **provided the backend is accessible**.

Current deployment points to: `http://143.47.179.233:5003`

To deploy elsewhere:
1. Update the frontend API URLs to point to your backend instance (manual find/replace)
2. Deploy all files (excluding backend/ if hosting backend separately)
3. Ensure backend is reachable from the frontend (CORS must be configured appropriately)

No build step is required - copy all files to the static hosting service preserving directory structure.