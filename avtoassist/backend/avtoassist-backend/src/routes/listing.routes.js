'use strict';
const router = require('express').Router();
const { requireAuth, optionalAuth } = require('../middleware/auth.middleware');
const upload = require('../middleware/upload');
const {
  browse, detail, create, update, remove, myListings, toggleFavorite, favorites,
} = require('../controllers/listingController');
const { addReview, listReviews } = require('../controllers/providerReviewController');

const asyncHandler = fn => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

// Public (optionalAuth — sevimlilarni belgilash uchun)
router.get('/',           optionalAuth, asyncHandler(browse));
router.get('/my',         requireAuth, asyncHandler(myListings));
router.get('/favorites',  requireAuth, asyncHandler(favorites));

// Provayder sharhlari
router.get('/provider/:providerId/reviews', asyncHandler(listReviews));
router.post('/provider/:providerId/review', requireAuth, asyncHandler(addReview));

router.get('/:id',        optionalAuth, asyncHandler(detail));

// Sevimli toggle
router.post('/:id/favorite', requireAuth, asyncHandler(toggleFavorite));

// Provider only (controller checks Provider record)
router.post('/',
  requireAuth,
  upload.array('images', 5),
  asyncHandler(create),
);

router.put('/:id',
  requireAuth,
  upload.array('images', 5),
  asyncHandler(update),
);

router.delete('/:id',
  requireAuth,
  asyncHandler(remove),
);

module.exports = router;
