const crypto = require('crypto');

function hashDocumentNumber(documentNumber) {
  return crypto.createHash('sha256').update(documentNumber.trim().toUpperCase()).digest('hex');
}

function runAutomatedKyc(input) {
  const { documentNumber, fullName, hasDocumentPhoto, hasSelfie } = input;

  if (!documentNumber || !fullName) {
    return { approved: false, reason: 'missing_fields', score: 0 };
  }
  if (!hasDocumentPhoto) {
    return { approved: false, reason: 'document_photo_missing', score: 0 };
  }
  if (!hasSelfie) {
    return { approved: false, reason: 'liveness_selfie_missing', score: 0 };
  }

  const hash = crypto.createHash('md5').update(documentNumber + fullName).digest('hex');
  const score = parseInt(hash.slice(0, 2), 16) % 101;

  const approved = score >= 35;

  return {
    approved,
    reason: approved ? null : 'low_confidence_score',
    score,
  };
}

module.exports = { runAutomatedKyc, hashDocumentNumber };
