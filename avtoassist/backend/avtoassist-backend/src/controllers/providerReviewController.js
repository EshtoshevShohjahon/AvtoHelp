'use strict';
const { ProviderReview, Provider, User } = require('../models');

// Provayder reytingini qayta hisoblaymiz
async function _recompute(providerId) {
  const rows = await ProviderReview.findAll({
    where: { provider_id: providerId },
    attributes: ['rating'],
  });
  const count = rows.length;
  const avg = count ? rows.reduce((s, r) => s + r.rating, 0) / count : 0;
  await Provider.update(
    { rating_avg: Math.round(avg * 10) / 10, rating_count: count },
    { where: { id: providerId } },
  );
}

// POST /marketplace/provider/:providerId/review
async function addReview(req, res) {
  const { providerId } = req.params;
  const { rating, comment } = req.body;

  const r = Number(rating);
  if (!r || r < 1 || r > 5) {
    return res.status(400).json({ error: 'rating_1_to_5_required' });
  }

  const provider = await Provider.findByPk(providerId);
  if (!provider) return res.status(404).json({ error: 'not_found' });

  // O'z-o'ziga baho berishni taqiqlaymiz
  if (provider.user_id === req.user.id) {
    return res.status(403).json({ error: 'cannot_review_self' });
  }

  const [review, created] = await ProviderReview.findOrCreate({
    where: { provider_id: providerId, user_id: req.user.id },
    defaults: { rating: r, comment: comment || null },
  });
  // Mavjud bo'lsa yangilaymiz
  if (!created) {
    await review.update({ rating: r, comment: comment || null });
  }

  await _recompute(providerId);

  res.status(201).json({ ok: true });
}

// GET /marketplace/provider/:providerId/reviews
async function listReviews(req, res) {
  const { providerId } = req.params;
  const reviews = await ProviderReview.findAll({
    where: { provider_id: providerId },
    include: [{ model: User, attributes: ['full_name'] }],
    order: [['created_at', 'DESC']],
    limit: 50,
  });

  res.json({
    reviews: reviews.map(rv => ({
      id: rv.id,
      rating: rv.rating,
      comment: rv.comment,
      author: rv.User?.full_name || 'Mijoz',
      created_at: rv.created_at,
    })),
  });
}

module.exports = { addReview, listReviews };
