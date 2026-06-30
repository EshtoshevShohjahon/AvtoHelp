'use strict';
const { Provider } = require('../models');
const kycService = require('../services/kycService');
const { requiresKyc } = require('../utils/kyc');
const { v4: uuidv4 } = require('uuid');

// POST /api/providers/register — usta KYC (tasdiqlash) hujjatlarini yuboradi
async function registerProvider(req, res) {
  const { document_number, document_photo_url, selfie_url, sector, service_type } = req.body;
  if (!document_number) {
    return res.status(400).json({ error: 'document_number required' });
  }

  let provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) {
    provider = await Provider.create({
      id: uuidv4(),
      user_id: req.user.id,
      sector: sector || null,
      service_type: service_type || null,
    });
  }

  // Avtomatik KYC (hujjat raqami + ism + foto/selfie mavjudligi bo'yicha)
  const kyc = kycService.runAutomatedKyc({
    documentNumber: document_number,
    fullName: req.user.full_name,
    hasDocumentPhoto: Boolean(document_photo_url),
    hasSelfie: Boolean(selfie_url),
  });

  await provider.update({
    document_number_hash: kycService.hashDocumentNumber(document_number),
    kyc_status: kyc.approved ? 'auto_approved' : 'auto_rejected',
    kyc_reject_reason: kyc.reason || null,
    kyc_checked_at: new Date(),
    is_verified: kyc.approved,
  });

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
  // Mijoz bilan ishlaydigan sektorlar uchun onlayn bo'lishdan oldin KYC majburiy
  if (is_online && requiresKyc(provider.sector) && !provider.is_verified) {
    return res.status(403).json({ error: 'verification_required' });
  }
  // Provider modeli `status` enum ishlatadi ('online' | 'offline' | 'busy')
  await provider.update({ status: is_online ? 'online' : 'offline' });
  res.json({ is_online: provider.status === 'online' });
}

async function updateLocation(req, res) {
  // lat/lng (yoki eski lon) qabul qilamiz
  const lat = req.body.lat;
  const lng = req.body.lng != null ? req.body.lng : req.body.lon;
  if (lat == null || lng == null) return res.status(400).json({ error: 'lat and lng required' });
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  if (!provider) return res.status(404).json({ error: 'provider profile not found' });
  await provider.update({ current_lat: parseFloat(lat), current_lng: parseFloat(lng) });
  const io = req.app.get('io');
  if (io) io.emit('provider_location', {
    providerId: provider.id, lat: provider.current_lat, lng: provider.current_lng,
  });
  res.json({ ok: true });
}

module.exports = { registerProvider, getMyProvider, setStatus, updateLocation };
