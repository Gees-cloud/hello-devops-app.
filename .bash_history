nano index.js
{   "name": "hello-devops",;   "version": "1.0.0",;   "description": "A simple Node.js app for DevOps CI/CD pipeline",;   "main": "index.js",;   "scripts": {;     "start": "node index.js";   },;   "dependencies": {;     "express": "^4.17.1";   },;   "author": "YourName",;   "license": "ISC"; }
nano package.json
sudo yum update -y
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs
node -v
npm -v
npm install
node index.js
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
exist
docker --version
docker info
Is
nano Dockerfile
docker build -t hello-node-app .
nano package.json
docker build -t hello-node-app .
docker build -t hello-node-app .k[200~docker build -t hello-node-app .~
nano package.json
docker build -t hello-node-app .
cat > package.json <<'EOF'
{
  "name": "hello-devops",
  "version": "1.0.0",
  "description": "A simple Node.js app for DevOps CI/CD pipeline",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.17.1"
  },
  "author": "Gloria",
  "license": "ISC"
}
EOF

cat package.json
docker build -t hello-node-app .
docker run -p 80:3000 -d hello-node-app
docker ps
docker run -p 80:3000 -d hello-node-app
docker ps
docker rm <docker ps -a>
docker rm <CONTAINER_ID>
docker run -p 80:3000 hello-node-app
nano index.js
cat > index.js <<'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from DevOps! Your Node.js app is running.');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
EOF

docker build -t hello-node-app .
docker run -p 80:3000 -d hello-node-app
docker ps
