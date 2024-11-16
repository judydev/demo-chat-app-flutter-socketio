# Use an official Node.js runtime as the base image
FROM node:23-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY . .

# Install the app dependencies
RUN npm install

# Expose port 8080 to allow Cloud Run to connect to the app
EXPOSE 8080

# Command to run the application
CMD ["node", "index.js"]
