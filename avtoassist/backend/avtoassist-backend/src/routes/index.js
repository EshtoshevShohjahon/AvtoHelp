'use strict';
const router = require('express').Router();

router.use('/auth', require('./auth.routes'));
router.use('/users', require('./user.routes'));
router.use('/providers', require('./provider.routes'));
router.use('/orders', require('./order.routes'));
router.use('/parts-stores', require('./partsStore.routes'));
router.use('/workshops', require('./workshop.routes'));
router.use('/payments', require('./payment.routes'));
router.use('/reviews', require('./review.routes'));
router.use('/content', require('./content.routes'));
router.use('/marketplace', require('./listing.routes'));

module.exports = router;
