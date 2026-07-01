'use strict';
const router = require('express').Router();
const { requireAuth } = require('../middleware/auth.middleware');
const { list, unreadCount, markAllRead } = require('../controllers/notificationController');

const asyncHandler = fn => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

router.get('/',             requireAuth, asyncHandler(list));
router.get('/unread-count', requireAuth, asyncHandler(unreadCount));
router.post('/read-all',    requireAuth, asyncHandler(markAllRead));

module.exports = router;
