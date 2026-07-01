const { OtpCode } = require('../models');

const OTP_TTL_MINUTES = 5;

function generateCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

async function sendOtp(phone) {
  const code = generateCode();
  const expires_at = new Date(Date.now() + OTP_TTL_MINUTES * 60 * 1000);

  await OtpCode.create({ phone, code, expires_at });

  if (process.env.OTP_DEBUG_MODE === 'true') {
    console.log(`[OTP-DEBUG] ${phone} -> ${code}`);
    return { sent: true, debugCode: code };
  }

  return { sent: true, debugCode: null };
}

async function verifyOtp(phone, code) {
  const record = await OtpCode.findOne({
    where: { phone, code, consumed: false },
    order: [['created_at', 'DESC']],
  });

  if (!record) return { valid: false, reason: 'invalid' };
  if (record.expires_at < new Date()) return { valid: false, reason: 'expired' };

  record.consumed = true;
  await record.save();
  return { valid: true };
}

module.exports = { sendOtp, verifyOtp };
