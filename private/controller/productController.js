import productModel from '../model/productModel.js';
import cloudinary from './cloudinary.js';

// Helper function to handle Cloudinary uploads using a Buffer
const uploadToCloudinary = (buffer) => {
    return new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
            { folder: 'herbalife/products' },
            (error, result) => {
                if (error) return reject(error);
                resolve(result);
            }
        );
        uploadStream.end(buffer);
    });
};

export function selectById(req, res) {
    const id = req.params.id;
    productModel.selectById(id, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.length === 0) return res.status(404).json({ message: "Product not found" });
        const data = result[0];
        res.status(200).json({
            success: true,
            message: "Product loaded",
            data: data,
        });
    });
}

export function selectAll(req, res) {
    productModel.selectAll((err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(404).json({ message: "No products found" });
        res.status(200).json({
            success: true,
            message: "Products loaded",
            data: results,
        });
    });
}

export async function create(req, res) {
    const { name, price, point } = req.body;
    try {
        let uploadedImageUrl = null;
        if (req.file) {
            const uploadResponse = await uploadToCloudinary(req.file.buffer);
            uploadedImageUrl = uploadResponse.secure_url;
        }

        productModel.create({ name, price, point, image_url: uploadedImageUrl }, (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(200).json({
                success: true,
                message: "Product created",
                data: result.insertId,
            });
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

export async function deleteitem(req, res) {
    const id = req.params.id;

    // 1. Get the product first to find the image URL
    productModel.selectById(id, async (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!result || result.length === 0) return res.status(404).json({ message: "Product not found" });

        const product = result[0];
        const imageUrl = product.image_url;

        try {
            // 2. If it's a Cloudinary URL, delete the image from Cloudinary
            if (imageUrl && imageUrl.includes('res.cloudinary.com')) {
                const regex = /\/upload\/(?:v\d+\/)?(.+)\.[a-z]+$/;
                const match = imageUrl.match(regex);
                if (match && match[1]) {
                    const publicId = match[1];
                    await cloudinary.uploader.destroy(publicId);
                }
            }

            // 3. Delete from local database
            productModel.delete(id, (err, deleteResult) => {
                if (err) return res.status(500).json({ error: err.message });
                res.status(200).json({
                    success: true,
                    message: "Product and associated image deleted",
                    data: deleteResult.affectedRows,
                });
            });
        } catch (error) {
            res.status(500).json({ error: "Cloudinary deletion failed: " + error.message });
        }
    });
}

export async function update(req, res) {
    const { id, name, price, point, image_url } = req.body;
    try {
        let uploadedImageUrl = image_url;
        
        // If a new file is provided, upload it and replace the image_url
        if (req.file) {
            const uploadResponse = await uploadToCloudinary(req.file.buffer);
            uploadedImageUrl = uploadResponse.secure_url;
        }

        productModel.update({ id, name, price, point, image_url: uploadedImageUrl }, (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(200).json({
                success: true,
                message: "Product updated",
                data: result.affectedRows,
            });
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}
