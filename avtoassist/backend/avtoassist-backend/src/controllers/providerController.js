'use strict';
const { Provider } = require('../models');
const kycService = require('../services/kycService');
const { v4: uuidv4 } = require('uuid');

async function registerProvider(req, res) {
  const { service_type, company_name, document_number, document_photo_url, selfie_url } = req.body;
  if (!service_type || !document_number) {
    return res.status(400).json({ error: 'service_type and document_number required' });
  }

  let provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) {
    provider = await Provider.create({
      id: uuidv4(),
      user_id: req.user.id,
      service_type,
      company_name: company_name || null,
      document_number,
      document_photo_url: document_photo_url || null,
      selfie_url: selfie_url || null,
      kyc_status: 'pending',
      is_online: false,
      lat: null,
      lon: null,
    });
  }

  const kyc = await kycService.runAutomatedKyc({ document_number, document_photo_url, selfie_url });
  await provider.update({ kyc_status: kyc.status, kyc_score: kyc.score });
  res.status(201).json({ provider, kyc });
}

async function getMyProvider(req, res) {
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) return res.status(404).json({ error: 'provider profile not found' });
  res.json(provider);
}

async function setStatus(req, res) {
  const { is_online } = req.body;
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) return res.status(404).json({ error: 'provider profile not found' });
  await provider.update({ is_online: Boolean(is_online) });
  res.json({ is_online: provider.is_online });
}

async function updateLocation(req, res) {
  const { lat, lon } = req.body;
  if (lat == null || lon == null) return res.status(400).json({ error: 'lat and lon required' });
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) return res.status(404).json({ error: 'provider profile not found' });
  await provider.update({ lat: parseFloat(lat), lon: parseFloat(lon) });
  const io = req.app.get('io');
  if (io) io.emit('provider_location', { providerId: provider.id, lat: provider.lat, lon: provider.lon });
  res.json({ ok: true });
}

module.exports = { registerProvider, getMyProvider, setStatus, updateLocation };
