package com.example.projectManagement.model;

import com.example.projectManagement.enums.UserRole;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class Developer extends  User{
    public Developer() {
    }
    public Developer(String name, String userUID, String email) {
        super(name, userUID, email, "Developer");
    }

    private Firestore db;
    @PostConstruct
    private void init() {
        try {
            db = FirestoreClient.getFirestore();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public List<String> viewProject(String userUID){
        List<String> projects;
        ApiFuture<DocumentSnapshot> future = db.collection("user").document(userUID).get();
        try {
            DocumentSnapshot document = future.get();
            if (document.exists()) {
                 projects = (List) document.get("projectsAlloted");
                 return projects;
            } else {
                System.out.println("No such document!");
                return null;
            }
        } catch (Exception e) {
            System.out.println("Error in getting project" + e.getMessage());
            return null;
        }
    }

    public void reportWork(String userUID,String projectId, String projectTitle, String description, double enteredHours, String selectedWorkCategory, String userId, HashMap<String, Object> workCategories){
        DocumentReference userRef = db.collection("users").document(userUID);
        CollectionReference clientsRef = db.collection("Clients");
        DocumentReference projectRef = clientsRef.document(projectTitle);
        try {
            ApiFuture<DocumentSnapshot> projectSnapshotFuture = projectRef.get();
            DocumentSnapshot projectSnapshot = projectSnapshotFuture.get();
            if (projectSnapshot.exists()) {
                projectRef.update("work", workCategories).get();
            } else {
                System.out.println("Project not found: " + projectTitle);
            }
            DocumentSnapshot userSnapshot = userRef.get().get();
            Map<String, Object> userData = userSnapshot.getData();
            assert userData != null;
            String userName = (String) userData.getOrDefault("name", "No Name Provided");
            double time = ((double) userData.getOrDefault("timeWorked", 0L)) + enteredHours;
            userRef.update("timeWorked", time).get();

            // Adding work entry
            DocumentReference workEntryRef = db.collection("Work").document();
            ApiFuture<WriteResult> workEntryFuture = workEntryRef.set(Map.of(
                    "Client", projectTitle,
                    "Date", Timestamp.now().toDate(),
                    "Description", description,
                    "Hours", enteredHours,
                    "Work", selectedWorkCategory,
                    "employeeName", userName,
                    "uid", userId
            ));
            workEntryFuture.get();
            userRef.update(
                    "timeWorked", time
            ).get();
        } catch (InterruptedException | ExecutionException e) {
            System.out.println("Error updating user's time worked: " + e.getMessage());
        }
    }

    public double getWorkedHours(String userUID){
        DocumentReference userRef = db.collection("users").document(userUID);
        try {
            DocumentSnapshot userSnapshot = userRef.get().get();
            Map<String, Object> userData = userSnapshot.getData();
            assert userData != null;
            return (double) userData.getOrDefault("timeWorked", 0L);
        } catch (InterruptedException | ExecutionException e) {
            System.out.println("Error getting user's time worked: " + e.getMessage());
            return 0.0;
        }
    }


}
