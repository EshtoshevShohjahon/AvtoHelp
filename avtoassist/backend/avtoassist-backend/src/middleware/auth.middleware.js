const { verifyAccessToken } = require('../utils/jwt');
const { User } = require('../models');

async function requireAuth(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) return res.status(401).json({ error: req.t('unauthorized') });

    const payload = verifyAccessToken(token);
    const user = await User.findByPk(payload.sub);
    if (!user) return res.status(401).json({ error: req.t('unauthorized') });

    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ error: req.t('unauthorized') });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: req.t('forbidden') });
    }
    next();
  };
}

module.exports = { requireAuth, requireRole };
