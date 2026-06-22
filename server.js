require('dotenv').config({ path: './private/.env' });
const express = require('express');
const app = express();
const cors = require('cors');

// Import Routes
const authRoutes = require('./private/routes/authRoutes');
const profileRoutes = require('./private/routes/profileRoutes');
const invoiceRoutes = require('./private/routes/invoiceRoutes');
const transactionRoutes = require('./private/routes/transactionRoutes');

// Improved CORS configuration
app.use(cors({
  origin: '*', // Allow all origins for development
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

app.use(express.json());

// Use Routes
app.use('/api', authRoutes);
app.use('/api', profileRoutes);
app.use('/api', invoiceRoutes);
app.use('/api', transactionRoutes);

app.listen(3000, () => console.log('Server started on port 3000'));
