# CareHome Connect

A full-stack Care Home Management System for managing residents, staff,
care plans, medication, daily care, incidents, risk assessments, shifts,
family communication, notifications, reports, and user accounts.

Built with Flutter (web) on the frontend, Node.js + Express on the backend,
and PostgreSQL for the database.

## Live demo

- Frontend: https://carehomesystem1.netlify.app
- Backend: https://care-management-backend-o47p.onrender.com
- Database: Neon (managed PostgreSQL)

## Tech stack

- Frontend: Flutter 3.47.5, Dart
- Backend: Node.js 20, Express.js
- Database: PostgreSQL 14+ (Neon in production)
- Auth: JWT with bcrypt password hashing
- Email: Resend (optional, used for staff invitations)
- Deployment: Netlify (frontend), Render (backend), Neon (database)

## Features

- Public website with Home, About, What We Do, Services, Contact, and
  Company Information pages
- Single login page with a role selector
- Four role-based dashboards:
  - Administrator
  - Manager / Senior Carer
  - Care Worker
  - Family Member
- Residents, care plans, care tasks, care notes
- Medications and medication administration records
- Risk assessments, incidents, staff, shifts and rota
- Family links, messages, notifications, documents
- Reports and audit logs
- Settings and Roles and Permissions reference

Family members only see information about the residents they are linked to.
The backend enforces this, not the UI.


## Live demo

Try the app without installing anything:

- **Frontend:** https://carehomesystem1.netlify.app
- **Backend API:** https://care-management-backend-o47p.onrender.com
- **Database:** Neon (managed PostgreSQL)

Note: the backend runs on Render's free tier, so the first request after
15 minutes of inactivity can take up to 50 seconds to wake up.

## Demo accounts

Log in with any of these. Use the same URL:
https://carehomesystem1.netlify.app/#/login

| Role | Email | Password |
|---|---|---|
| Administrator | admin@carehome.local | ChangeThisNow123! |
| Manager / Senior Carer | manager@carehome.local | Manager123! |
| Care Worker | worker@carehome.local | Worker123! |
| Family Member | family@carehome.local | Family123! |

The role buttons on the login page are only a hint. The backend always
checks the real role stored in the database.

## 5-minute tour of the app

If you only have a few minutes, do this in order.

### 1. Log in as Administrator

Go to the login page, click **Administrator**, and use the admin credentials
above.

You will land on the Administrator dashboard. In the left sidebar you can see
every module in the system.

### 2. Add a resident

Click **Residents** in the sidebar. Click **Add Resident** and fill in a name,
room number, and status. Save.

The new resident now appears in the list.

### 3. Add staff

Click **Staff** in the sidebar. Click **Add Staff** or **Invite Staff**.

- **Add Staff** creates an account with a password you set. The user can log
  in right away.
- **Invite Staff** sends an email with a link the person uses to set their
  own password. It requires the backend to have a Resend API key configured.

Pick a role from the dropdown: Administrator, Manager / Senior Carer,
Care Worker, or Family Member.

### 4. Link a family member to a resident

Click **Family Links** in the sidebar. Click **Add Link**, pick a resident
and a family user, add their relationship (Daughter, Son, Spouse), and save.

The family member can now see only that resident's data.

### 5. Add a care plan

Click **Care Plans** in the sidebar. Click **Add Care Plan**. Fill in a title,
care need, goal, and review date. Save.

### 6. Add a medication

Click **Medication**. Click **Add Medication**. Fill in the medication name,
dosage, frequency, and route. Save.

### 7. Check the audit logs

Click **Audit Logs**. Every important action you just performed is recorded
here: resident created, staff created, family link created, and so on.

### 8. Log out and log in as Manager

Click **Logout** at the bottom of the sidebar. Log in with
`manager@carehome.local` / `Manager123!`.

Notice the sidebar is different. The Manager has different permissions than
the Administrator. The Manager can create and edit records, but cannot
manage users or view audit logs.

### 9. Log in as Care Worker

Log out. Log in with `worker@carehome.local` / `Worker123!`.

The Care Worker can view residents, complete tasks, record medication, and
write care notes. They cannot create residents or edit care plans.

### 10. Log in as Family Member

Log out. Log in with `family@carehome.local` / `Family123!`.

The Family dashboard shows only the linked relative's information:
their room, their care plan, their medications, and any family-visible
care notes.

The family member cannot see other residents anywhere in the app.
The backend enforces this even if the family user tries to call an API
directly.