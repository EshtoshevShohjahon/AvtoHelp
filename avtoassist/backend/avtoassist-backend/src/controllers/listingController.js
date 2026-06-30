'use strict';
const { Op } = require('sequelize');
const { Listing, Provider, User } = require('../models');
const path = require('path');
const fs = require('fs');

const BASE_URL = process.env.BASE_URL || 'http://localhost:4000';

function imageUrl(filename) {
  return `${BASE_URL}/uploads/${filename}`;
}

// GET /marketplace  — browse all active listings (client + guest)
async function browse(req, res) {
  const { vehicle_category, listing_type, category, q, limit = 30, offset = 0 } = req.query;

  const where = { is_active: true };
  if (vehicle_category && vehicle_category !== 'all') {
    where.vehicle_category = { [Op.in]: [vehicle_category, 'both'] };
  }
  if (listing_type) where.listing_type = listing_type;
  if (category) where.category = { [Op.iLike]: `%${category}%` };
  if (q) {
    where[Op.or] = [
      { title: { [Op.iLike]: `%${q}%` } },
      { description: { [Op.iLike]: `%${q}%` } },
    ];
  }

  const rows = await Listing.findAll({
    where,
    include: [{
      model: Provider,
      as: 'provider',
      attributes: ['id', 'rating_avg', 'rating_count', 'sector', 'is_verified'],
      include: [{ model: User, attributes: ['full_name', 'phone'] }],
    }],
    order: [['created_at', 'DESC']],
    limit: Math.min(Number(limit), 100),
    offset: Number(offset),
  });

  // increment views lazily (fire and forget)
  Listing.increment('views', {
    where: { id: rows.map(r => r.id) },
  }).catch(() => {});

  res.json({
    listings: rows.map(_format),
    count: rows.length,
  });
}

// GET /marketplace/:id
async function detail(req, res) {
  const listing = await Listing.findByPk(req.params.id, {
    include: [{
      model: Provider,
      as: 'provider',
      attributes: ['id', 'rating_avg', 'rating_count', 'sector', 'is_verified', 'current_lat', 'current_lng'],
      include: [{ model: User, attributes: ['full_name', 'phone'] }],
    }],
  });
  if (!listing) return res.status(404).json({ error: 'not_found' });
  await listing.increment('views');
  res.json({ listing: _format(listing) });
}

// POST /marketplace  — provider creates listing (with images)
async function create(req, res) {
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) return res.status(403).json({ error: 'not_a_provider' });

  const { title, description, price, price_unit, price_type, listing_type, category, vehicle_category } = req.body;
  if (!title || !price) return res.status(400).json({ error: 'title_and_price_required' });

  const files = req.files || [];
  const images = files.map(f => f.filename);

  const listing = await Listing.create({
    provider_id: provider.id,
    title,
    description,
    price: Number(price),
    price_unit: price_unit || 'so\'m',
    price_type: price_type || 'fixed',
    listing_type: listing_type || 'service',
    category: category || null,
    vehicle_category: vehicle_category || 'both',
    images,
  });

  res.status(201).json({ listing: _format(listing) });
}

// PUT /marketplace/:id  — provider updates own listing
async function update(req, res) {
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) return res.status(403).json({ error: 'not_a_provider' });

  const listing = await Listing.findByPk(req.params.id);
  if (!listing) return res.status(404).json({ error: 'not_found' });
  if (listing.provider_id !== provider.id) return res.status(403).json({ error: 'forbidden' });

  const { title, description, price, price_unit, price_type, listing_type, category, vehicle_category, is_active, remove_images } = req.body;

  let images = [...listing.images];
  // Remove specified images
  if (remove_images) {
    const toRemove = Array.isArray(remove_images) ? remove_images : [remove_images];
    toRemove.forEach(fn => {
      images = images.filter(i => i !== fn);
      const full = path.join(__dirname, '../../uploads', fn);
      if (fs.existsSync(full)) fs.unlinkSync(full);
    });
  }
  // Add new images
  const newFiles = req.files || [];
  images.push(...newFiles.map(f => f.filename));

  await listing.update({
    title: title ?? listing.title,
    description: description ?? listing.description,
    price: price != null ? Number(price) : listing.price,
    price_unit: price_unit ?? listing.price_unit,
    price_type: price_type ?? listing.price_type,
    listing_type: listing_type ?? listing.listing_type,
    category: category ?? listing.category,
    vehicle_category: vehicle_category ?? listing.vehicle_category,
    is_active: is_active != null ? Boolean(JSON.parse(is_active)) : listing.is_active,
    images,
  });

  res.json({ listing: _format(listing) });
}

// DELETE /marketplace/:id
async function remove(req, res) {
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) return res.status(403).json({ error: 'not_a_provider' });

  const listing = await Listing.findByPk(req.params.id);
  if (!listing) return res.status(404).json({ error: 'not_found' });
  if (listing.provider_id !== provider.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'forbidden' });
  }

  // Delete image files
  listing.images.forEach(fn => {
    const full = path.join(__dirname, '../../uploads', fn);
    if (fs.existsSync(full)) fs.unlinkSync(full);
  });

  await listing.destroy();
  res.json({ ok: true });
}

// GET /marketplace/my  — provider's own listings
async function myListings(req, res) {
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) return res.status(403).json({ error: 'not_a_provider' });

  const rows = await Listing.findAll({
    where: { provider_id: provider.id },
    order: [['created_at', 'DESC']],
  });
  res.json({ listings: rows.map(_format) });
}

function _format(l) {
  const obj = l.toJSON ? l.toJSON() : l;

  // Provider'ni Flutter kutgan shaklga keltiramiz
  if (obj.provider) {
    const p = obj.provider;
    const u = p.User || p.user || {};
    obj.provider = {
      id: p.id,
      business_name: u.full_name || '',
      phone: u.phone || '',
      rating: p.rating_avg ?? 0,
      rating_count: p.rating_count ?? 0,
      sector: p.sector || null,
      is_verified: p.is_verified ?? false,
      lat: p.current_lat ?? null,
      lng: p.current_lng ?? null,
    };
  }

  return {
    ...obj,
    images: (obj.images || []).map(fn =>
      fn.startsWith('http') ? fn : imageUrl(fn)
    ),
  };
}

module.exports = { browse, detail, create, update, remove, myListings };
