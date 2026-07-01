const fs = require('fs');
const path = require('path');

const SUPPORTED_LANGUAGES = ['uz', 'uz-cyrl', 'ru', 'en'];
const DEFAULT_LANGUAGE = process.env.DEFAULT_LANGUAGE || 'uz';

const dictionaries = {};
for (const lang of SUPPORTED_LANGUAGES) {
  const filePath = path.join(__dirname, '..', 'locales', `${lang}.json`);
  dictionaries[lang] = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

function resolveLanguage(req) {
  const fromQuery = (req.query.lang || '').toLowerCase();
  if (SUPPORTED_LANGUAGES.includes(fromQuery)) return fromQuery;

  const header = (req.headers['accept-language'] || '').toLowerCase();
  for (const lang of SUPPORTED_LANGUAGES) {
    if (header.includes(lang)) return lang;
  }
  if (header.startsWith('ru')) return 'ru';
  if (header.startsWith('en')) return 'en';

  return DEFAULT_LANGUAGE;
}

function translate(lang, key, vars = {}) {
  const dict = dictionaries[lang] || dictionaries[DEFAULT_LANGUAGE];
  let text = dict[key] || dictionaries[DEFAULT_LANGUAGE][key] || key;
  for (const [k, v] of Object.entries(vars)) {
    text = text.replace(new RegExp(`{{${k}}}`, 'g'), v);
  }
  return text;
}

module.exports = { SUPPORTED_LANGUAGES, DEFAULT_LANGUAGE, resolveLanguage, translate };
