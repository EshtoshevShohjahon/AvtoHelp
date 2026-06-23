async function charge({ orderId, amount }) {
  if (!process.env.PAYME_MERCHANT_ID) {
    console.warn('[Payme] PAYME_MERCHANT_ID sozlanmagan — simulyatsiya rejimida ishlamoqda');
  }
  return { success: true, providerRef: `PAYME-SIM-${orderId.slice(0, 8)}` };
}

module.exports = { charge };
