# Project-Management

## Description
This is a project management system where admin can create projects and assign developers to the project. Developers can report their work and admin can view the work done by developers. Developers can also give feedback to the admin.

## Team Members
- Nandish N S
- Nandan N Prabhu
- Manoj Kumar R
- Sai Kashyap

## Features
- Admin can create projects
- Admin can assign developers to the project
- Developers can report their work
- Admin can view the reported work by developers
- Developers can give feedback to the admin

## Classes Used :
```bash
- User
- Project
- Developer
- Feedback
```
## Controllers Used :
```bash
- UserController
- ProjectController
- DeveloperController
- FeedbackController
```
## Interfaces Used :
```bash
- RoleCommand
```

## Design Patterns Used :
```bash
- Singleton
- Builder
- Command
- Proxy 
```

## Repositories Used in frontend :
```bash
- UserRepository
- ProjectRepository
- DeveloperRepository
- FeedbackRepository
```

## Installation
- Clone the repository
- Open the project in Android Studio
- Run the project `flutter run`

## Tech Stack
- Flutter
- Dart
- Spring Boot
- Firebase


## Architecture Doc :
```bash
https://docs.google.com/document/d/1aElxaWmm3P4CgDD5zbvk9qGfD3xiag4-bakvjaDZdMY/edit
```

## git commands :
```bash
git clone https://github.com/nandishns/Project-Management.git
```

```bash
git status
```
Taking a pull from main
```bash
git pull
```
Pushing your changes to current branch
```bash
git push
```
Creating a branch
```bash
git checkout -b <branch-name>
```
Changing to new branch
```bash
git checkout <branch-name>
```

## Endpoints :
```bash
const String BASE_URL = "http://localhost:8080";
const String CREATE_ACCOUNT = "/user/create";
const String ADMIN_STATUS = "/user/getAdminStatus";
const String ACTIVE_STATUS = "/user/getActiveStatus";
const String CREATE_PROJECT = "/project/create";
const String GET_ALL_PROJECTS = "/project/getAll";
const String ASSIGN_DEVELOPER = "/project/assignDeveloper";
const String PROJECT_DETAILS = "/project/getByProjectId";
const String UPDATE_PROJECT = "/project/update";
const String REPORT_WORK = '/developer/reportWork';
const String WORKED_HOURS = '/developer/getWorkedHours';
const String CREATE_FEEDBACK = '/developer/createFeedback';
const String GET_FEEDBACK = '/developer/getFeedback';
```


##
resources for report : docs.google.com/document/d/1YZrBm2OyBWMZ-8HgZxy6SNWLDdGKkGlwzp86wXs_k8c

