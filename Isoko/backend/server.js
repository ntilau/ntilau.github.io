const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 5003;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage for users (fallback when MongoDB is not available)
const users = new Map();
let userIdCounter = 1;

// JWT secret
const JWT_SECRET = 'isoko_secret_key_2026';

// Helper function to find user by email
function findUserByEmail(email) {
  for (const [id, user] of users.entries()) {
    if (user.email === email) {
      return user;
    }
  }
  return null;
}

// Helper function to find user by ID
function findUserById(id) {
  return users.get(id) || null;
}

// Routes

// User registration
app.post('/register', async (req, res) => {
  try {
    const { email, password, companyName, firstName, lastName, telNo, country, tradeRole } = req.body;

    // Check if user already exists
    if (findUserByEmail(email)) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    const newUser = {
      id: userIdCounter++,
      email,
      password: hashedPassword,
      firstName,
      lastName,
      companyName,
      telNo,
      country: country || 'India',
      tradeRole: tradeRole || 'Buyer'
    };

    users.set(newUser.id, newUser);

    // Create JWT token
    const payload = {
      user: {
        id: newUser.id
      }
    };

    jwt.sign(
      payload,
      JWT_SECRET,
      { expiresIn: '1h' },
      (err, token) => {
        if (err) throw err;
        res.json({ token });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// User login
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if user exists
    const user = findUserByEmail(email);
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Create JWT token
    const payload = {
      user: {
        id: user.id
      }
    };

    jwt.sign(
      payload,
      JWT_SECRET,
      { expiresIn: '1h' },
      (err, token) => {
        if (err) throw err;
        res.json({
          token,
          user: {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            companyName: user.companyName
          }
        });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get user by token (middleware to verify token)
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) return res.status(401).json({ message: 'Access token required' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid or expired token' });
    req.user = user;
    next();
  });
};

// Get user data
app.get('/users/:token', authenticateToken, async (req, res) => {
  try {
    const user = findUserById(req.user.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    // Return user without password
    const { password, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get electronics products
app.get('/electronics/:category', async (req, res) => {
  try {
    // For now, return mock data since we don't have the actual products in DB
    // In a real implementation, you would filter by category
    const mockProducts = [
      {
        id: 1,
        productTitle: 'pinhole 1/2.8" cctv lens EFL=1.8mm cctv camera lens wide-angle low distortion',
        price: 685.38,
        qty: 10,
        productImg: [
          "https://sc04.alicdn.com/kf/H64ed7e1732cc415b9f519ec657cb2b28b.jpg",
          "https://sc04.alicdn.com/kf/H6d011b913b6348ae94e727b8b33d26f6C.jpg",
          "https://sc04.alicdn.com/kf/Hfed98582f4d748118f663859b33800c9p.jpg"
        ]
      },
      {
        id: 2,
        productTitle: 'BENRO T980 Aluminum Light Weight Digital Camera Tripod Stand for Photography and Live Broadcast with Carry Bag',
        price: 2804.64,
        qty: 10,
        productImg: [
          "https://sc04.alicdn.com/kf/Hadcb3eb2388342cea3a4899e6e66b9113.jpg",
          "https://sc04.alicdn.com/kf/Hcdd6bd8ce3284a928569ecf22674940cx.jpg",
          "https://sc04.alicdn.com/kf/H08146a4cfc1f4c63adb1a12b52f35a0fI.jpg"
        ]
      },
      {
        id: 3,
        productTitle: 'Newest E99 RC Drones With Camera 720P or 4K hd Camera Wifi FPV Optical Flow Positioning 20mins Flight Foldable Dron',
        price: 846.33,
        qty: 10,
        productImg: [
          "https://sc04.alicdn.com/kf/H86db3d4c5c044e889cdf05a2020ddc932.jpg",
          "https://sc04.alicdn.com/kf/Hebe4154eee8142bda7adee60b56607dej.jpg",
          "https://sc04.alicdn.com/kf/H735e879f8fab4c9092fc53577b3add96B.jpg"
        ]
      }
    ];

    res.json(mockProducts);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ message: 'Isoko.app Backend API is running' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;