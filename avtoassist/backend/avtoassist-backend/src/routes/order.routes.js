'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const { createOrder, getOrder, listMyOrders, updateOrderStatus } = require('../controllers/orderController');

router.use(requireAuth);
router.post('/', asyncHandler(createOrder));
router.get('/mine', asyncHandler(listMyOrders));
router.get('/:id', asyncHandler(getOrder));
router.patch('/:id/status', asyncHandler(updateOrderStatus));

module.exports = router;
