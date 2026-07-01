'use strict';
const { Review, Provider } = require('../models');
const { v4: uuidv4 } = require('uuid');
const { Op } = require('sequelize');

async function createReview(req, res) {
  const { order_id, provider_id, rating, comment } = req.body;
  if (!provider_id || !rating) return res.status(400).json({ error: 'provider_id and rating required' });
  if (rating < 1 || rating > 5) return res.status(400).json({ error: 'rating must be 1-5' });

  const review = await Review.create({
    id: uuidv4(),
    order_id: order_id || null,
    customer_id: req.user.id,
    provider_id,
    rating: parseInt(rating),
    comment: comment || null,
  });

  const reviews = await Review.findAll({ where: { provider_id } });
  const avg = reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;
  await Provider.update({ rating_avg: Math.round(avg * 100) / 100, rating_count: reviews.length }, { where: { id: provider_id } });

  res.status(201).json(review);
}

async function listReviews(req, res) {
  const reviews = await Review.findAll({
    where: { provider_id: req.params.providerId },
    order: [['createdAt', 'DESC']],
    limit: 50,
  });
  res.json(reviews);
}

module.exports = { createReview, listReviews };
