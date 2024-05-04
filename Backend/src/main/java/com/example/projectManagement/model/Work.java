package com.example.projectManagement.model;

import com.google.api.core.ApiFuture;
import com.google.auto.value.extension.serializable.SerializableAutoValue;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Service
public class Work {

    private Firestore db;
    @PostConstruct
    private void init() {
        try {
            db = FirestoreClient.getFirestore();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public List<HashMap<String,Object>> getReportedWork() {
      try{
          List<HashMap<String,Object>> reportedWork = new ArrayList<>();
          ApiFuture<QuerySnapshot> future = db.collection("Work").get();
          future.get().getDocuments().forEach(documentSnapshot -> {
              System.out.println(documentSnapshot.getData());
              reportedWork.add((HashMap<String, Object>) documentSnapshot.getData());
          });
          return reportedWork;
      }catch(Exception ignored){
           return null;
      }
    }

    public void updateWork(HashMap<String,Object> updatedWorkDetails) {
        try{
            ApiFuture<QuerySnapshot> future = db.collection("Work").get();
            future.get().getDocuments().forEach(documentSnapshot -> {
                if(documentSnapshot.getId().equals((String) updatedWorkDetails.get("workId"))){
                    db.collection("Work").document(documentSnapshot.getId()).set(updatedWorkDetails);
                }
            });
        }catch(Exception e){
            System.out.println("Error in updating work" + e.getMessage());
        }
    }



}
