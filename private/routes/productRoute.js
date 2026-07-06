import express from 'express';
import multer from 'multer';
import { selectById, selectAll, create, deleteitem, update } from '../controller/productController.js';

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

router.get('/getpall', selectAll);
router.get('/getpby/:id', selectById);
router.post('/createp', upload.single('image'), create);
router.put('/updatep', upload.single('image'), update);
router.delete('/deletep/:id', deleteitem);

export default router;
