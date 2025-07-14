 const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from DevOps! Your Node.js app is running.');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
