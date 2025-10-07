const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
require('dotenv').config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://mongodb-service:27017/capstone';

// Configure Winston logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'capstone-backend' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ],
});

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});

// Middleware
app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.FRONTEND_URL || '*',
  credentials: true
}));
app.use(limiter);
app.use(morgan('combined', { 
  stream: { write: message => logger.info(message.trim()) }
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// MongoDB connection with retry logic
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    
    logger.info(`MongoDB Connected: ${conn.connection.host}`);
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      logger.error('MongoDB connection error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });
    
    mongoose.connection.on('reconnected', () => {
      logger.info('MongoDB reconnected');
    });
    
  } catch (error) {
    logger.error('MongoDB connection failed:', error);
    process.exit(1);
  }
};

// Item Schema and Model
const ItemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Item name is required'],
    trim: true,
    maxlength: [100, 'Item name cannot exceed 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Item description is required'],
    trim: true,
    maxlength: [500, 'Item description cannot exceed 500 characters']
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'pending'],
    default: 'active'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Add indexes for better performance
ItemSchema.index({ createdAt: -1 });
ItemSchema.index({ status: 1 });
ItemSchema.index({ name: 'text', description: 'text' });

const Item = mongoose.model('Item', ItemSchema);

// Routes

// Health check endpoint
app.get('/health', (req, res) => {
  const healthCheck = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '1.0.0',
    memory: process.memoryUsage(),
    mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  };
  
  logger.info('Health check requested', { healthCheck });
  res.json(healthCheck);
});

// Get all items with pagination and filtering
app.get('/api/items', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    const status = req.query.status;
    const search = req.query.search;
    
    // Build filter object
    const filter = {};
    if (status) filter.status = status;
    if (search) filter.$text = { $search: search };
    
    const items = await Item.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();
    
    const total = await Item.countDocuments(filter);
    
    const result = {
      items,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    };
    
    logger.info('Items retrieved', { 
      count: items.length, 
      page, 
      limit, 
      total 
    });
    
    res.json(result);
  } catch (error) {
    logger.error('Error fetching items:', error);
    res.status(500).json({ 
      error: 'Failed to fetch items',
      message: error.message 
    });
  }
});

// Get single item by ID
app.get('/api/items/:id', async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);
    
    if (!item) {
      return res.status(404).json({ 
        error: 'Item not found',
        id: req.params.id 
      });
    }
    
    logger.info('Item retrieved', { id: item._id });
    res.json(item);
  } catch (error) {
    logger.error('Error fetching item:', error);
    
    if (error.name === 'CastError') {
      return res.status(400).json({ 
        error: 'Invalid item ID format',
        id: req.params.id 
      });
    }
    
    res.status(500).json({ 
      error: 'Failed to fetch item',
      message: error.message 
    });
  }
});

// Create new item
app.post('/api/items', async (req, res) => {
  try {
    const { name, description, status } = req.body;
    
    // Validation
    if (!name || !description) {
      return res.status(400).json({ 
        error: 'Name and description are required' 
      });
    }
    
    const item = new Item({
      name: name.trim(),
      description: description.trim(),
      status: status || 'active'
    });
    
    await item.save();
    
    logger.info('Item created', { 
      id: item._id, 
      name: item.name 
    });
    
    res.status(201).json(item);
  } catch (error) {
    logger.error('Error creating item:', error);
    
    if (error.name === 'ValidationError') {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: Object.values(error.errors).map(err => err.message)
      });
    }
    
    res.status(500).json({ 
      error: 'Failed to create item',
      message: error.message 
    });
  }
});

// Update item
app.put('/api/items/:id', async (req, res) => {
  try {
    const { name, description, status } = req.body;
    
    const updateData = {};
    if (name !== undefined) updateData.name = name.trim();
    if (description !== undefined) updateData.description = description.trim();
    if (status !== undefined) updateData.status = status;
    updateData.updatedAt = new Date();
    
    const item = await Item.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );
    
    if (!item) {
      return res.status(404).json({ 
        error: 'Item not found',
        id: req.params.id 
      });
    }
    
    logger.info('Item updated', { 
      id: item._id, 
      name: item.name 
    });
    
    res.json(item);
  } catch (error) {
    logger.error('Error updating item:', error);
    
    if (error.name === 'CastError') {
      return res.status(400).json({ 
        error: 'Invalid item ID format',
        id: req.params.id 
      });
    }
    
    if (error.name === 'ValidationError') {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: Object.values(error.errors).map(err => err.message)
      });
    }
    
    res.status(500).json({ 
      error: 'Failed to update item',
      message: error.message 
    });
  }
});

// Delete item
app.delete('/api/items/:id', async (req, res) => {
  try {
    const item = await Item.findByIdAndDelete(req.params.id);
    
    if (!item) {
      return res.status(404).json({ 
        error: 'Item not found',
        id: req.params.id 
      });
    }
    
    logger.info('Item deleted', { 
      id: item._id, 
      name: item.name 
    });
    
    res.json({ 
      message: 'Item deleted successfully',
      item 
    });
  } catch (error) {
    logger.error('Error deleting item:', error);
    
    if (error.name === 'CastError') {
      return res.status(400).json({ 
        error: 'Invalid item ID format',
        id: req.params.id 
      });
    }
    
    res.status(500).json({ 
      error: 'Failed to delete item',
      message: error.message 
    });
  }
});

// Metrics endpoint for monitoring
app.get('/metrics', (req, res) => {
  const metrics = {
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: process.cpuUsage(),
    version: process.env.npm_package_version || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    mongodb: {
      status: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
      host: mongoose.connection.host,
      port: mongoose.connection.port,
      name: mongoose.connection.name
    }
  };
  
  res.json(metrics);
});

// 404 handler
app.use('*', (req, res) => {
  logger.warn('404 - Route not found', { 
    method: req.method, 
    url: req.originalUrl 
  });
  
  res.status(404).json({ 
    error: 'Route not found',
    method: req.method,
    url: req.originalUrl
  });
});

// Global error handler
app.use((error, req, res, next) => {
  logger.error('Unhandled error:', error);
  
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    mongoose.connection.close(false, () => {
      logger.info('MongoDB connection closed');
      process.exit(0);
    });
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    mongoose.connection.close(false, () => {
      logger.info('MongoDB connection closed');
      process.exit(0);
    });
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', async () => {
  await connectDB();
  logger.info(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
});

module.exports = app;