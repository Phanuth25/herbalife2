import { v2 as cloudinary } from 'cloudinary'; // Recommended to use v2 for Cloudinary
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

// 1. Recreate __dirname for ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 2. Configure dotenv using the absolute path
dotenv.config({ path: path.resolve(__dirname, '../.env') });

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

export default cloudinary;