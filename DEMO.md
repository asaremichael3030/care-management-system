# CareHome Connect - Demo Guide

A guided tour of the app for first-time users.

## What is CareHome Connect

CareHome Connect is a management system for a residential care home. It helps
care home staff manage residents, care plans, medication, daily care, and
family communication in one place.

There are four types of users:

- **Administrator** - manages user accounts, system settings, and audit logs
- **Manager / Senior Carer** - manages residents, care plans, medication,
  staff, and shifts
- **Care Worker** - provides daily care to residents and records what they do
- **Family Member** - sees approved information about their relative

Residents themselves do not have login accounts. They are people receiving
care, not app users.

## Before you start

- Open https://carehomesystem1.netlify.app
- The first request may take up to 50 seconds if the backend has been idle
- Use one of the demo accounts below

## Demo accounts

| Role | Email | Password |
|---|---|---|
| Administrator | admin@carehome.local | ChangeThisNow123! |
| Manager | manager@carehome.local | Manager123! |
| Care Worker | worker@carehome.local | Worker123! |
| Family Member | family@carehome.local | Family123! |

## Part 1: Administrator walkthrough

### Log in

1. Open https://carehomesystem1.netlify.app/#/login
2. Click the **Administrator** button at the top left of the form
3. Enter `admin@carehome.local` and the password
4. Click **Login**

You land on the Administrator dashboard.

### Understand the dashboard

The dashboard is a summary page. You see:

- Four stat cards at the top with counts
- A donut chart showing the resident mix
- A staff overview panel
- Recent activities and recent residents

These are currently mock values that will become real once you add data
through the app.

### Create a resident

1. Click **Residents** in the left sidebar
2. Click **Add Resident**
3. Fill in:
   - First Name: Jane
   - Last Name: Doe
   - Date of Birth: 1945-05-12
   - Gender: Female
   - Room: 22
   - Admission Date: today's date
   - Status: active
   - Emergency Contact Name: John Doe
   - Emergency Contact Phone: 555-0100
   - Care Needs: Needs help with dressing in the morning
   - Allergies: Penicillin
4. Click **Save Resident**

Jane Doe appears in the Residents list.

### Create a staff account

1. Click **Staff**
2. Click **Add Staff**
3. Fill in:
   - First Name: Alice
   - Last Name: Smith
   - Email: alice@carehome.local
   - Password: AlicePass1
   - Role: Care Worker
   - Job Title: Senior Care Worker
   - Department: Main Unit
   - Employment Status: active
4. Click **Save Staff**

Alice can now log in with her email and password.

### Create a care plan for Jane

1. Click **Care Plans**
2. Click **Add Care Plan**
3. Pick Jane Doe from the resident dropdown
4. Fill in:
   - Title: Morning Care Plan
   - Care Need: Assistance with dressing
   - Goal: Maintain independence
   - Care Actions: Assist every morning at 8 AM
   - Frequency: Daily
   - Status: active
5. Click **Save**

### Add medication for Jane

1. Click **Medication**
2. Click **Add Medication**
3. Pick Jane Doe
4. Fill in:
   - Medication Name: Paracetamol
   - Dosage: 500mg
   - Frequency: Twice daily
   - Route: Oral
   - Instructions: Take with water
   - Prescriber: Dr. Ahmed
5. Click **Save Medication**

### Link a family member

1. Click **Family Links**
2. Click **Add Link**
3. Pick Jane Doe as the resident
4. Pick `family@carehome.local` as the family user
5. Relationship: Daughter
6. Tick **Primary contact**
7. Click **Save**

The family user can now see Jane's information.

### Check the audit logs

1. Click **Audit Logs**
2. You will see every action you just performed, with timestamps, the user
   who did it, and the entity that was affected

### Verify the users page

1. Click **Users**
2. You will see every account in the system
3. You can edit a user, reset their password, activate or deactivate them,
   or delete them

## Part 2: Manager walkthrough

### Log out and log in as Manager

1. Click **Logout** at the bottom of the sidebar
2. Log in as `manager@carehome.local` / `Manager123!`

### Notice the difference

The Manager sidebar does not have Users, Roles and Permissions, or Audit
Logs. Managers can create and edit records but cannot manage user accounts
or view the audit trail.

The Manager does have Access to Care Workers, Daily Care, Risk
Assessments, Messages, and Reports.

### Try to open Audit Logs directly

Even if you type the URL for audit logs in the browser, the backend will
return a 403 error. The frontend just hides the link, but the backend is
the real security gate.

## Part 3: Care Worker walkthrough

### Log out and log in as Care Worker

1. Log out
2. Log in as `worker@carehome.local` / `Worker123!`

### The Care Worker experience

The sidebar shows: Dashboard, My Residents, Today's Tasks, Care Plans,
Medication, Care Notes, Incidents, My Shifts, Messages, Notifications,
Settings, Logout.

### Record a medication

1. Click **Medication**
2. Find a medication in the list
3. Click **Record**
4. Choose a status: given, refused, missed, or held
5. Add an optional note
6. Click **Save**

The record is now in the system. Managers and Administrators will see it in
the medication history.

### Write a care note

1. Click **Care Notes**
2. Click **Add Note**
3. Pick a resident
4. Choose a note type (Observation, Personal Care, Activity, etc.)
5. Write the note
6. Decide whether it is visible to family (tick the box)
7. Click **Save Note**

If the note is marked family-visible, the linked family member will see it
in their Care Updates page.

### Report an incident

1. Click **Incidents**
2. Click **Report Incident**
3. Fill in the incident type, date, time, location, description, and any
   action taken
4. Submit

Managers and Administrators can review and update the incident later.

## Part 4: Family Member walkthrough

### Log out and log in as Family Member

1. Log out
2. Log in as `family@carehome.local` / `Family123!`

### The Family experience

The Family sidebar is different again. It shows: Dashboard, My Relative,
Care Plan, Medication, Care Updates, Activities, Care Team, Messages,
Notifications, Documents, Contact Care Home, Settings, Logout.

### See the linked relative

The dashboard header shows the linked resident's name, room, and status.
If you completed the earlier steps as Administrator, this shows Jane Doe
in Room 22.

### Check what the family can and cannot see

1. Click **Care Plan** - you see Jane Doe's care plans
2. Click **Medication** - you see Jane Doe's medications
3. Click **Care Updates** - you see Jane Doe's family-visible care notes

Notice you never see any other residents. The system only shows your linked
relative. This is enforced on the backend, so it works even if the URL is
manually edited.

### Send a message to the care home

1. Click **Messages**
2. Click **New Message**
3. Pick an Administrator or Manager from the dropdown
4. Write a subject and a message
5. Send

Now log out and log back in as that Administrator or Manager. Open
**Messages**. The message is waiting in the inbox. Reply. The family
member will see the reply the next time they log in.

### Contact the care home

1. Click **Contact Care Home**
2. Fill in a subject and a message
3. Send

The message is delivered to a care home staff member. A copy appears in
the family's own Sent folder.

## Common questions

### Why does the login page have four role buttons

Because it is convenient for users. But the role buttons are only a hint.
The real role is checked by the backend every time the user makes a
request. Selecting Administrator and logging in with Family Member
credentials gives you the Family dashboard, not the Administrator one.

### Can residents log in

No. Residents are not app users. They are people receiving care.

### How do I add more users

Only the Administrator can create accounts. Use the Staff page for staff
roles and family members, or the Invite Staff button for email-based
invitations.

### How do I reset a password

Administrators can reset any user's password from the Users page. Users
can change their own password from Settings.

### What if a family member needs to see a different resident

The Administrator or Manager can update the Family Links from the Family
Links page. Remove the current link and add a new one.

## Where to get help

This is a demo project. If you find a bug or have a question, open an issue
on the GitHub repository.