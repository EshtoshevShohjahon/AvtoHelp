'use strict';
const { User, RefreshToken } = require('../models');
const otpService = require('../services/otpService');
const { signAccessToken } = require('../utils/jwt');
const { v4: uuidv4 } = require('uuid');
const jwt = require('jsonwebtoken');

async function issueTokens(userId) {
  const accessToken = signAccessToken({ id: userId });
  const raw = uuidv4();
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
  await RefreshToken.create({ id: uuidv4(), user_id: userId, token: raw, expires_at: expiresAt });
  return { accessToken, refreshToken: raw };
}

async function sendOtpHandler(req, res) {
  const { phone } = req.body;
  if (!phone) return res.status(400).json({ error: 'phone required' });
  const result = await otpService.sendOtp(phone);
  res.json({ sent: result.sent, debug_code: result.debugCode || null });
}

async function verifyOtpHandler(req, res) {
  const { phone, code } = req.body;
  if (!phone || !code) return res.status(400).json({ error: 'phone and code required' });
  const ok = await otpService.verifyOtp(phone, code);
  if (!ok.valid) return res.status(401).json({ error: 'invalid or expired otp' });

  let user = await User.findOne({ where: { phone } });
  if (!user) {
    user = await User.create({
      id: uuidv4(),
      phone,
      role: 'client',
      preferred_language: 'uz',
    });
  }
  const tokens = await issueTokens(user.id);
  res.json({ ...tokens, user: { id: user.id, phone: user.phone, role: user.role } });
}

async function refreshHandler(req, res) {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(400).json({ error: 'refreshToken required' });
  const record = await RefreshToken.findOne({ where: { token: refreshToken } });
  if (!record || record.revoked || new Date() > record.expires_at) {
    return res.status(401).json({ error: 'invalid refresh token' });
  }
  await record.update({ revoked: true });
  const tokens = await issueTokens(record.user_id);
  res.json(tokens);
}

async function logoutHandler(req, res) {
  const { refreshToken } = req.body;
  if (refreshToken) {
    await RefreshToken.update({ revoked: true }, { where: { token: refreshToken } });
  }
  res.json({ ok: true });
}

module.exports = { sendOtpHandler, verifyOtpHandler, refreshHandler, logoutHandler };
