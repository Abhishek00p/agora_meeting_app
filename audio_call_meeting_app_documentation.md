
# Audio Call Meeting App Documentation

## Overview
An **Audio Call Meeting App** built using **Flutter**, **GetX**, and **Agora SDK** with Firebase Firestore as the backend for data storage.  
The app supports multiple user roles and provides secure, role-based access for hosting and joining audio-only meetings with specific meeting rules and restrictions.

---
## User Roles
1. **Admin**  
   - Can register new members.  
   - Can create meetings.  
   - Can manage associated members.  

2. **Member**  
   - Registered under an Admin.  
   - Can create meetings.  
   - Can manage associated users.  

3. **Normal User**  
   - Registered under a Member.  
   - Can join meetings only.  

4. **Guest (Free User / Outsider)**  
   - Can join public meetings as a trial user.  
   - Limited meeting access (e.g., trial duration).  

---

## Role-Based Permissions

| Feature                  | Admin   | Member   | User   | Guest       |
|:-------------------------|:--------|:---------|:-------|:------------|
| Login                    | Yes     | Yes      | Yes    | Yes         |
| Host Meeting             | Yes     | Yes      | No     | No          |
| Join Meeting             | Yes     | Yes      | Yes    | Yes (Trial) |
| Register Member          | Yes     | No       | No     | No          |
| Register User            | No      | Yes      | No     | No          |
| View Associated Members  | Yes     | No       | No     | No          |
| View Associated Users    | No      | Yes      | No     | No          |
| Promote to Subhost       | Yes     | Yes      | No     | No          |
| Approve Speaking Request | Yes     | Yes      | No     | No          |

---

## Screens & Features

### 1. Login Page
- **Fields:** Email, Password  
- **UI Elements:** App logo, Login button  
- **Behavior:** No “Forgot Password” option.  

### 2. Home Page
- **Top Info Card:** Displays: Full Name, Member Code, Role, Plan Expiry Date, Days Left  
- **Sections:**
  - Host Meeting: Start new meeting + recent meetings list  
  - Join Meeting: Join button + recent joined meetings list  
- **Meeting Card:** Date, Time, Title, Duration, Host Name, Participants Count, Status  
- **App Bar:** Users icon → Associated Members/Users Page  

### 3. Associated Members Page (Admin Only)
- Register new members: Full Name, Email, Password, Purchase Date, Subscription Plan, Max Participants, Active Toggle, Auto-generated Member Code  

### 4. Associated Users Page (Member Only)
- Register new users under the member: Full Name, Email, Password, Auto-filled Member Code, Plan Expiry (same as member)  

### 5. Associated Member/User Detail Page
- Full Name, Email, Password, Member Code  

---

## Meeting Management

### Meeting Creation (Admin/Member only)
- Fields: Title, Password, Duration, Max Participants, Schedule?, Requires Approval?  

### Join Meeting
- Fields: Meeting ID, Password (optional)  

### Meeting Room UI
- **App Bar:** Title, Remaining Time, Settings (ID & Pass)  
- **Bottom Bar:** Mic, Speaker, End Call  
- **Body:** Grid View (max 6 per screen), restricted views based on role  
- **Host Controls:** Force Mute/Unmute, Kick, Promote to Subhost  

---

## Meeting Rules
1. Host can hear all participants.  
2. Participants cannot hear each other (except Host/Subhost).  
3. Participants hear Host/Subhost only.  
4. All participants muted by default.  
5. Speaking requires Host approval.  

---

## Firestore Structure

```json
{
  "meetingId": "string",
  "title": "string",
  "password": "string",
  "hostName": "string",
  "hostId": "string",
  "maxParticipants": number,
  "memberCode": "string",
  "scheduleStartTime": "timestamp",
  "scheduleEndTime": "timestamp",
  "actualStartTime": "timestamp",
  "actualEndTime": "timestamp",
  "totalUniqueParticipants": number,
  "status": "upcoming | ongoing | ended"
}
```

---

## Technical Requirements
- **Framework:** Flutter  
- **State Management:** GetX  
- **Realtime Communication:** Agora SDK  
- **Database:** Firebase Firestore  
- **Authentication:** Firebase Auth  

---

## Flow Diagrams

### Meeting Creation Flow
digraph {
    rankdir=LR
    node [shape=box, style=rounded]

    Start [label="Admin/Member Initiates Meeting Creation"]
    InputDetails [label="Input Meeting Title, Optional Password,\nDuration, Max Participants,\nSchedule Option, Requires Approval"]
    Validate [label="Validate Inputs"]
    StoreDB [label="Store Meeting Details in Firestore"]
    Notify [label="Notify Associated Users (if any)"]
    End [label="Meeting Created Successfully"]

    Start -> InputDetails -> Validate -> StoreDB -> Notify -> End
}

### Join Meeting Flow
digraph {
    rankdir=LR
    node [shape=box, style=rounded]

    Start [label="User Opens Join Meeting Page"]
    InputIDPass [label="Enter Meeting ID and Optional Password"]
    Validate [label="Validate Meeting Credentials in Firestore"]
    CheckStatus [label="Check Meeting Status"]
    Join [label="Join Meeting Room"]
    Deny [label="Show Error (Invalid ID/Password or Meeting Ended)"]

    Start -> InputIDPass -> Validate
    Validate -> CheckStatus [label="Valid"]
    Validate -> Deny [label="Invalid"]
    CheckStatus -> Join [label="Ongoing or Upcoming"]
    CheckStatus -> Deny [label="Ended or Full"]
}

