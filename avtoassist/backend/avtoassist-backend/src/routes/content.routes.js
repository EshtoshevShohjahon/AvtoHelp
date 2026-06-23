'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { getServices } = require('../controllers/contentController');

router.get('/services', asyncHandler(getServices));

module.exports = router;
