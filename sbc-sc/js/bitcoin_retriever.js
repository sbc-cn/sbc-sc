const axios = require('axios').default;

async function getLatestBlockData() {
  let data;
  data = await axios.get("https://blockchain.info/latestblock/")
				    .then((res) => {
				      return res.data;
				    })
				    .catch(() => console.log("Get latest bitcoin block data failed."));
  return data;
}

async function getTransactionDataByIdx(idx) {
  let data;
  data = await axios.get("https://blockchain.info/rawtx/" + idx)
				    .then((res) => {
				      return res.data;
				    })
				    .catch(() => console.log("Get bitcoin transaction data failed for index ", idx));
  return data;
}

async function getLatestBlockHeightAndMinerAddress() {
  const blockData = await getLatestBlockData();
  const blockHeight = blockData.height;
  const coinbaseTransactionIdx = blockData.txIndexes[0];
  const transactionData = await getTransactionDataByIdx(coinbaseTransactionIdx)
  const address = transactionData.out[0].addr;
  console.log("The Latest block height is", blockHeight, "and its miner address is", address);
  return {blockHeight, address};
}

const {height, address} = getLatestBlockHeightAndMinerAddress();
