const { resolveLanguage, translate } = require('../config/i18n');

module.exports = function i18nMiddleware(req, res, next) {
  const lang = resolveLanguage(req);
  req.lang = lang;
  req.t = (key, vars) => translate(lang, key, vars);
  res.setHeader('Content-Language', lang);
  next();
};
