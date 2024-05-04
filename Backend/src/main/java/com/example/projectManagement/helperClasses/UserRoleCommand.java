package com.example.projectManagement.helperClasses;

import com.example.projectManagement.interfaces.RoleCommand;
import com.example.projectManagement.model.User;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.cloud.FirestoreClient;

import javax.annotation.PostConstruct;
import java.util.List;

public class UserRoleCommand implements RoleCommand {

    private Firestore db;
    @PostConstruct
    private void init() {
        try {
            db = FirestoreClient.getFirestore();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public String execute(String name, String userUID, String email, String role, boolean isAdmin, boolean isActive, List<String> projectsAlloted,String github) {
      try{
          User user = new User(name, userUID, email, role, false, isActive, projectsAlloted, github);
          System.out.println("**** in userCreation class : User: " + user.isAdmin());
          ApiFuture<WriteResult> result = db.collection("users").document(userUID).set(user);
          return result.get().getUpdateTime().toString();
      }
        catch(Exception e){
            System.out.println("Error in creating user" + e.getMessage());
            return null;
        }
    }
}
