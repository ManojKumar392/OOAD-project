package com.example.projectManagement.model;

import com.example.projectManagement.helperClasses.Context;
import com.example.projectManagement.helperClasses.OperationMultiply;
import com.google.api.core.ApiFuture;
import com.google.auto.value.extension.serializable.SerializableAutoValue;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.firebase.cloud.FirestoreClient;
import com.google.protobuf.Api;
import jakarta.annotation.PostConstruct;
import org.checkerframework.checker.units.qual.A;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Service
public class Work {
    @Autowired
    private ApplicationContext context;
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

    public double getPayDetails(String userUID){
        double hours = 0;
        try{
            ApiFuture<QuerySnapshot> future = db.collection("Work").whereEqualTo("uid",userUID).get();
            for (QueryDocumentSnapshot document : future.get().getDocuments()) {
                hours += document.getDouble("pay");
            }
            Context _context  = context.getBean(Context.class,context.getBean(OperationMultiply.class));
            _context.executeStrategy(hours,200);
        }catch(Exception e){
            e.printStackTrace();
        }
        return hours;
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