package com.example.projectManagement.helperClasses;

import com.example.projectManagement.interfaces.RoleCommand;
import com.example.projectManagement.model.User;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
public class AdminRoleCommand implements RoleCommand {

    private Firestore db;
    @PostConstruct
    private void init() {
        try {
            db = FirestoreClient.getFirestore();
            System.out.println("Firestore initialized: " + (db != null));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public AdminRoleCommand() {
    }

    public String execute(String name, String userUID, String email, String role, boolean isAdmin, boolean isActive, List<String> projectsAlloted, String github) {
        if (this.db == null) {
            System.out.println("Firestore database not initialized");
            throw new IllegalStateException("Firestore database not initialized");
        }
       try{
           User user = new User(name, userUID, email, role,true, isActive, projectsAlloted, github);
           System.out.println("**** in adminCreation class : User: " + user.isAdmin());

           ApiFuture<WriteResult> result = db.collection("users").document(userUID).set(user);
           return result.get().getUpdateTime().toString();
       } catch(Exception e){
           System.out.println("Error in creating user" + e.getMessage());
           return null;
       }
    }
}
