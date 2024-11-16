const express = require('express');
const http = require('http');
const socketIo = require('socket.io');

// Initialize Express and HTTP server
const app = express();
const server = http.createServer(app);

const PORT = process.env.PORT || 8080;

// Initialize Socket.IO
const io = socketIo(server);

app.get('/', (_, res) => {
  res.send('Socket.IO Server is running');
});

// Handle socket connections
io.on('connection', (socket) => {
  console.log('User connected');

  socket.on('message', (data) => {
    // send message to all connected clients except the sender
    // https://socket.io/docs/v4/broadcasting-events/
    socket.broadcast.emit('message', data);
  });

  // Handle disconnection
  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

// Start the server
server.listen(PORT, () => {
  console.log(`Socket.IO server listening on port ${PORT}`);
});
