package com.example.projectManagement.model;

import com.example.projectManagement.helperClasses.AdminRoleCommand;
import com.example.projectManagement.interfaces.RoleCommand;
import com.example.projectManagement.helperClasses.UserRoleCommand;
import com.example.projectManagement.helperClasses.Invoker;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Primary;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;
import javax.annotation.PostConstruct;
import java.util.List;
import java.util.Map;
@Service
@Primary
public class User  {
    private Invoker invoker;
    private String name;
    private String userUID;
    private String email;
    private String role;
    private boolean isAdmin;
    private boolean isActive;
    private List<String> projectsAlloted;

    private String github;

    public User(String name, String userUID, String email, String role, boolean isAdmin, boolean isActive, List<String> projectsAlloted, String gitHubId) {
        this.name = name;
        this.userUID = userUID;
        this.email = email;
        this.role = role;
        this.isAdmin = isAdmin;
        this.isActive = isActive;
        this.projectsAlloted = projectsAlloted;
        this.github = gitHubId;
    }
    public User(String name, String userUID, String email, String userRole) {
        this.name = name;
        this.userUID = userUID;
        this.email = email;
        this.role = userRole;
    }
    @Autowired
    private ApplicationContext context;

    public User(){}

    private Firestore db;
    @PostConstruct
    private void init() {
        try {
            db = FirestoreClient.getFirestore();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public String getName() {
        return name;
    }



    public String getUserUID() {
        return userUID;
    }

    public String getEmail() {
        return email;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    public boolean isActive() {
        return isActive;
    }

    public List<String> getProjectsAlloted() {
        return projectsAlloted;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setUserUID(String userUID) {
        this.userUID = userUID;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = String.valueOf(role);
    }

    public String createUser(String userUID, String email, String name, String role, Boolean isAdmin, Boolean isActive, List projectsAlloted, String github) throws Exception {
        RoleCommand roleCommand;
        if (role.equals("Developer")) {
            roleCommand = context.getBean(UserRoleCommand.class);
        } else if (role.equals("Tech Lead")||role.equals("Project Manager")) {
            System.out.println("AdminRoleCommand");
            roleCommand = context.getBean(AdminRoleCommand.class);
        } else {
            throw new IllegalArgumentException("Unsupported role: " + role);
        }
        var roleInvoker = context.getBean(Invoker.class);
        roleInvoker.setCommand(roleCommand);
        return roleInvoker.invoke(name, userUID, email, role,isAdmin, isActive, projectsAlloted, github);
    }


    public Map<String,Object> getUser(String userUID) throws Exception {
        ApiFuture<DocumentSnapshot> future = db.collection("users").document(userUID).get();
//        System.out.println("User: " + future.get());
        return future.get().getData();
    }


    public Boolean getAdminStatus(String userUID) throws Exception {
        ApiFuture<DocumentSnapshot> future = db.collection("users").document(userUID).get();
        DocumentSnapshot documentSnapshot = future.get();
//        System.out.println("User: " + documentSnapshot);
        if (documentSnapshot.exists()) {
            if (documentSnapshot.contains("admin")) {
                return documentSnapshot.getBoolean("admin");
            } else {
                throw new Exception("The 'admin' field is missing in the document.");
            }
        } else {
            throw new Exception("Document with userUID " + userUID + " does not exist.");
        }
    }

    public String deleteUser(String id) throws Exception {
        return null;
    }


    public String authenticateUsingGoogleAuth() throws Exception {
        return null;
    }

    public Boolean getActiveStatus(String userUID) throws Exception {
        ApiFuture<DocumentSnapshot> future = db.collection("users").document(userUID).get();
        DocumentSnapshot documentSnapshot = future.get();
//        System.out.println("User: " + documentSnapshot);
        if (documentSnapshot.exists()) {
            if (documentSnapshot.contains("active")) {
                return documentSnapshot.getBoolean("active");
            } else {
                throw new Exception("The 'active' field is missing in the document.");
            }
        } else {
            throw new Exception("Document with userUID " + userUID + " does not exist.");
        }
    }

    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                ", userUID='" + userUID + '\'' +
                ", email='" + email + '\'' +
                ", role ='" + role + '\'' +
                '}';
    }


}
