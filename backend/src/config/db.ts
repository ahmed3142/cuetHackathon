import mongoose from "mongoose";
import { envConfig } from "./envConfig";

const MAX_RETRIES = 5;
const INITIAL_RETRY_DELAY = 1000; // 1 second

export const connectDB = async (retryCount = 0): Promise<void> => {
  try {
    console.log(`Attempting to connect to MongoDB (attempt ${retryCount + 1}/${MAX_RETRIES})...`);
    
    await mongoose.connect(envConfig.mongo.uri, {
      dbName: envConfig.mongo.dbName,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    
    console.log("✓ Connected to MongoDB successfully");
    console.log(`  Database: ${envConfig.mongo.dbName}`);
    console.log(`  Connection state: ${mongoose.connection.readyState}`);
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error('MongoDB connection error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('MongoDB disconnected. Attempting to reconnect...');
    });
    
    mongoose.connection.on('reconnected', () => {
      console.log('✓ MongoDB reconnected');
    });
    
  } catch (error) {
    console.error(`✗ MongoDB connection failed (attempt ${retryCount + 1}/${MAX_RETRIES}):`, error);
    
    if (retryCount < MAX_RETRIES - 1) {
      const delay = INITIAL_RETRY_DELAY * Math.pow(2, retryCount);
      console.log(`  Retrying in ${delay/1000} seconds...`);
      await new Promise(resolve => setTimeout(resolve, delay));
      return connectDB(retryCount + 1);
    } else {
      console.error('✗ Max retries reached. Exiting...');
      process.exit(1);
    }
  }
};
