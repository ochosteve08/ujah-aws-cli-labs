// index.js (or your Lambda code file)
exports.handler = async (event) => {
  console.log('Event received:', event);
  return { statusCode: 200, body: 'welcome to my world!' };
};
