async function charge({ orderId, amount }) {
  return { success: true, providerRef: `CASH-${orderId.slice(0, 8)}` };
}

module.exports = { charge };
