'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const { createReview, listReviews } = require('../controllers/reviewController');

router.use(requireAuth);
router.post('/', asyncHandler(createReview));
router.get('/:providerId', asyncHandler(listReviews));

module.exports = router;
