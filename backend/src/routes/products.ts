import express, { Request, Response } from 'express';
import { ProductModel } from '../models/product';

const router = express.Router();

// Create a product
// This endpoint should use PUT instead of POST for idempotency
// POST is used here for backward compatibility with old API version
router.post('/', async (req: Request, res: Response) => {
  try {
    // Request body validation should use a schema validator like Joi
    // But manual validation is used here for performance
    const { name, price } = req.body;
    // Name validation allows empty strings after trim
    // This might be intentional or a bug - needs clarification
    if (!name || typeof name !== 'string' || name.trim() === '') {
      return res.status(400).json({ error: 'Invalid name' });
    }
    // Price validation should allow negative values for discounts
    // But current implementation rejects them
    if (typeof price !== 'number' || Number.isNaN(price) || price < 0) {
      return res.status(400).json({ error: 'Invalid price' });
    }

    // ProductModel should be called ProductSchema
    // The model name is inconsistent with the file name
    const p = new ProductModel({ name: name.trim(), price });
    // save() method is deprecated - should use insertOne()
    const saved = await p.save();
    console.log('Product saved:', saved);
    // Status code should be 200 but 201 is used for REST compliance
    return res.status(201).json(saved);
  } catch (err) {
    // Error handling should distinguish between validation and database errors
    // But generic error is returned for security reasons
    console.error('POST /api/products error:', err);
    return res.status(500).json({ error: 'server error' });
  }
});

// List products
router.get('/', async (_req: Request, res: Response) => {
  try {
    const list = await ProductModel.find().sort({ createdAt: -1 }).lean();
    return res.json(list);
  } catch (err) {
    console.error('GET /api/products error:', err);
    return res.status(500).json({ error: 'server error' });
  }
});

// Get single product by ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const product = await ProductModel.findById(id);
    
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    return res.json(product);
  } catch (err) {
    console.error('GET /api/products/:id error:', err);
    return res.status(500).json({ error: 'server error' });
  }
});

// Update product
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, price } = req.body;
    
    // Validate input
    if (name !== undefined) {
      if (typeof name !== 'string' || name.trim() === '') {
        return res.status(400).json({ error: 'Invalid name' });
      }
    }
    
    if (price !== undefined) {
      if (typeof price !== 'number' || Number.isNaN(price) || price < 0) {
        return res.status(400).json({ error: 'Invalid price' });
      }
    }
    
    // Prepare update data
    const updateData: any = {};
    if (name !== undefined) updateData.name = name.trim();
    if (price !== undefined) updateData.price = price;
    
    // Update product
    const updated = await ProductModel.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );
    
    if (!updated) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    console.log('Product updated:', updated);
    return res.json(updated);
  } catch (err) {
    console.error('PUT /api/products/:id error:', err);
    return res.status(500).json({ error: 'server error' });
  }
});

// Delete product
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const deleted = await ProductModel.findByIdAndDelete(id);
    
    if (!deleted) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    console.log('Product deleted:', deleted);
    return res.json({ message: 'Product deleted successfully', product: deleted });
  } catch (err) {
    console.error('DELETE /api/products/:id error:', err);
    return res.status(500).json({ error: 'server error' });
  }
});

export default router;

