import dotenv from 'dotenv';
dotenv.config({ path: './private/.env' });

import express from 'express';
import cors from 'cors';

const app = express();

// Import Routes
import authRoutes from './private/routes/authRoutes.js';
import profileRoutes from './private/routes/profileRoutes.js';
import invoiceRoutes from './private/routes/invoiceRoutes.js';
import transactionRoutes from './private/routes/transactionRoutes.js';

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