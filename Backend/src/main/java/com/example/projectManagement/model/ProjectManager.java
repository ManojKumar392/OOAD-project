package com.example.projectManagement.model;


import com.example.projectManagement.enums.UserRole;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class ProjectManager extends User {
    private Firestore db;
    @PostConstruct
    private void init() {
        try {
            db = FirestoreClient.getFirestore();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public ProjectManager() { }

    public void createProject(HashMap<String,Object> projectDetails) {
        try{
            ApiFuture<WriteResult> future = db.collection("Clients").document((String) projectDetails.get("name")).set(projectDetails);
            future.get();
            System.out.println("Project created");
        } catch (Exception e){
            System.out.println("Error in creating project" + e.getMessage());
        }
    }

    public List<HashMap<String, Object>> getAllProjects()  {
        try{
            List<HashMap<String,Object>> projects = new ArrayList<>();
            ApiFuture<QuerySnapshot> future = db.collection("Clients").get();
            future.get().getDocuments().forEach(documentSnapshot -> {
                System.out.println(documentSnapshot.getData());
                projects.add((HashMap<String, Object>) documentSnapshot.getData());
            });
            System.out.println("Projects retrieved"+ projects);
            return projects;
        }catch(Exception e){
            System.out.println("Error in getting all projects");
            return null;
        }
    }

    public void updateProject(HashMap<String,Object> updatedProjectDetails) {
        try{
            ApiFuture<WriteResult> future = db.collection("Clients").document((String) updatedProjectDetails.get("name")).set(updatedProjectDetails);
            future.get();
            System.out.println("Project updated");
        }catch (Exception e){
            System.out.println("Error in updating project" + e.getMessage());
        }
    }


    public HashMap<String,Object> getByProjectId(String projectId) {
        ApiFuture<DocumentSnapshot> future = db.collection("Clients").document(projectId).get();
        try {
            DocumentSnapshot document = future.get();
            if (document.exists()) {
                System.out.println(projectId + " data: " + document.getData());
                return (HashMap<String, Object>) document.getData();
            } else {
                System.out.println("No such document!");
            }
        } catch (Exception e) {
            System.out.println("Error in getting project by id");
        }
        System.out.println("Project viewed");
        return null;
    }

    public void addDevelopersToProject(String projectId,String userUID){
        try{
            ApiFuture<WriteResult> future = db.collection("users").document(userUID).update(
                    "projectsAlloted", FieldValue.arrayUnion(projectId)
            );
            future.get();
            System.out.println("Developers added to project");
        }catch (Exception e){
            System.out.println("Error in adding developers to project");
        }
    }

    public void deactivateProject(String projectId,String userUID) {
        try {
            ApiFuture<WriteResult> future = db.collection("Clients").document(projectId).update("active", false);
            future.get();
            System.out.println("Project deactivated");
        } catch (Exception e) {
            System.out.println("Error in deactivating project");
        }
    }

    public void removeDevelopersFromProject(String projectId){
        System.out.println("Developers removed from project");
    }

    public void getUpdatesFromDevelopers(String projectId){
        System.out.println("Updates received from developers");
    }
}