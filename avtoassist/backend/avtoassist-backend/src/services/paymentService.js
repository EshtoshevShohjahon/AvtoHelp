const cashProvider = require('../paymentProviders/cash');
const paymeProvider = require('../paymentProviders/payme');
const clickProvider = require('../paymentProviders/click');

const providers = {
  cash: cashProvider,
  card: paymeProvider,
  wallet: cashProvider,
};

async function processPayment({ orderId, amount, method }) {
  const provider = providers[method];
  if (!provider) {
    return { success: false, error: 'unsupported_method' };
  }
  return provider.charge({ orderId, amount });
}

module.exports = { processPayment, clickProvider, paymeProvider };
