async function charge({ orderId, amount }) {
  if (!process.env.CLICK_MERCHANT_ID) {
    console.warn('[Click] CLICK_MERCHANT_ID sozlanmagan — simulyatsiya rejimida ishlamoqda');
  }
  return { success: true, providerRef: `CLICK-SIM-${orderId.slice(0, 8)}` };
}

module.exports = { charge };
