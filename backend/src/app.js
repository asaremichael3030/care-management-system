const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const activitiesRoutes = require('./routes/activities');
const healthRoutes = require('./routes/health');
const authRoutes = require('./routes/auth');
const residentsRoutes = require('./routes/residents');
const usersRoutes = require('./routes/users');
const familyRoutes = require('./routes/family');
const carePlansRoutes = require('./routes/carePlans');
const careTasksRoutes = require('./routes/careTasks');
const careNotesRoutes = require('./routes/careNotes');
const medicationsRoutes = require('./routes/medications');
const riskAssessmentsRoutes = require('./routes/riskAssessments');
const incidentsRoutes = require('./routes/incidents');
const staffRoutes = require('./routes/staff');
const shiftsRoutes = require('./routes/shifts');
const messagesRoutes = require('./routes/messages');
const notificationsRoutes = require('./routes/notifications');
const documentsRoutes = require('./routes/documents');
const reportsRoutes = require('./routes/reports');
const auditLogsRoutes = require('./routes/auditLogs');
const invitationsRoutes = require('./routes/invitations');
const notFound = require('./middleware/notFound');
const errorHandler = require('./middleware/errorHandler');
const { loginLimiter } = require('./middleware/rateLimiter');

const app = express();

// Safer HTTP response headers.
app.use(helmet());

// Parse JSON with a reasonable size limit.
app.use(express.json({ limit: '1mb' }));

// Allow requests from the Flutter app during development.
app.use(cors());

// Simple request log for debugging.
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Rate limited login.
app.use('/api/auth/login', loginLimiter);

app.use('/api/health', healthRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/residents', residentsRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/family', familyRoutes);
app.use('/api/care-plans', carePlansRoutes);
app.use('/api/care-tasks', careTasksRoutes);
app.use('/api/care-notes', careNotesRoutes);
app.use('/api/medications', medicationsRoutes);
app.use('/api/risk-assessments', riskAssessmentsRoutes);
app.use('/api/incidents', incidentsRoutes);
app.use('/api/staff', staffRoutes);
app.use('/api/shifts', shiftsRoutes);
app.use('/api/messages', messagesRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/documents', documentsRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/audit-logs', auditLogsRoutes);
app.use('/api/invitations', invitationsRoutes);
app.use('/api/activities', activitiesRoutes);
app.use(cors());

app.use(notFound);
app.use(errorHandler);

module.exports = app;