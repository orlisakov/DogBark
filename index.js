const express = require('express');
const cors = require('cors');
const db = require('./config/db');
const port = 3000;
const bodyParser = require('body-parser');
const app = express();
const path = require('path');

// Serve static files from the "uploads" directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const userRoutes = require('./routes/user_routes');
const ProfileRoutes = require('./routes/profile_routes');
const requestRoutes = require('./routes/request_routes');
const taskRoutes = require('./routes/tasks_routes');
const MessageRoutes = require('./routes/message_routes');
const AdminRoutes = require('./routes/admin_routes');
const recommendationRoutes = require('./routes/recommendation_routes');
const scheduleRoutes = require('./routes/schedule_routes');
const additionsRoutes = require('./routes/additions_routes');
const postRoutes = require('./routes/post_routes');

// Increase the limit for JSON and URL-encoded bodies
app.use(bodyParser.json({ limit: '100mb' }));  // Increase as needed
app.use(bodyParser.urlencoded({ limit: '100mb', extended: true }));

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({extended: true}));

app.use('/', userRoutes);
app.use('/', ProfileRoutes);
app.use('/', requestRoutes); 
app.use('/', taskRoutes);
app.use('/', MessageRoutes);
app.use('/', AdminRoutes);
app.use('/', recommendationRoutes);
app.use('/', scheduleRoutes);
app.use('/', additionsRoutes); 
app.use('/', postRoutes);

app.listen(port, () => {
    console.log(`Server Listening on Port http://localhost:${port}`);
});