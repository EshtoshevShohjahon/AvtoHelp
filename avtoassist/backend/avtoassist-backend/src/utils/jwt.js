const jwt = require('jsonwebtoken');

const SECRET = process.env.JWT_SECRET || 'dev_secret_o_zgartiring';
const ACCESS_EXPIRES = process.env.JWT_ACCESS_EXPIRES || '15m';

function signAccessToken(user) {
  return jwt.sign(
    { sub: user.id, role: user.role, phone: user.phone },
    SECRET,
    { expiresIn: ACCESS_EXPIRES }
  );
}

function verifyAccessToken(token) {
  return jwt.verify(token, SECRET);
}

module.exports = { signAccessToken, verifyAccessToken };
