# Use an official Node.js runtime as a parent image
FROM node:16

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
# (if you had package-lock.json, you'd copy it too)
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Expose port 3000 (where your Node.js app runs)
EXPOSE 3000

# Define the command to run your app
CMD [ "node", "index.js" ]

