package com.example.projectManagement.model;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class Feedback {

    public Feedback() {}

    private Firestore db;

    @PostConstruct
    private void init() {
        try {
            db = FirestoreClient.getFirestore();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private Feedback(feedback_builder builder) {
        String feedback = builder.feedback;
        double star = builder.star;
    }
    public List<HashMap<String, Object>> getFeedback() {
        try {
            List<HashMap<String, Object>> feedback = new ArrayList<>();
            ApiFuture<QuerySnapshot> future = db.collection("Feedback").orderBy(
                    "date").get();
            future.get().getDocuments().forEach(documentSnapshot -> {
                feedback.add((HashMap<String, Object>) documentSnapshot.getData());
                System.out.println(documentSnapshot.getData());
            });
            return feedback;
        } catch (Exception e) {
            System.out.println("Error in getting feedback" + e.getMessage());
            return null;
        }
    }

    public String addFeedback(String feedback, double star) {
        try {
            HashMap<String, Object> feedbackMap = new HashMap<>();
            feedbackMap.put("feedback", feedback);
            feedbackMap.put("star", star);
            ApiFuture<WriteResult> result = db.collection("Feedback").document().set(feedbackMap);
            return result.get().getUpdateTime().toString();
        } catch (Exception e) {
            System.out.println("Error in adding feedback" + e.getMessage());
            return null;
        }
    }

    public static class feedback_builder {
        private String feedback;
        private double star;

        public feedback_builder() {
        }

        public feedback_builder setFeedback(String feedback) {
            this.feedback = feedback;
            return this;
        }

        public feedback_builder setStar(double star) {
            this.star = star;
            return this;
        }

        public Feedback build() {
            return new Feedback(this);
        }
    }
}