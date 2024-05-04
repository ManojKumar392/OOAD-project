package com.example.projectManagement.controller;

import com.example.projectManagement.model.Feedback;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.context.ApplicationContext;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;

@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping("/feedback")
public class FeedbackController {

    @Autowired
    private ApplicationContext context;
    @RequestMapping("/createFeedback")
    public ResponseEntity<String> setFeedback(@RequestBody HashMap<String,Object> feedbackDetails) {
       try{
           var star = feedbackDetails.containsKey("star") ? (double) feedbackDetails.get("star") : 0.0;
           Feedback feedbackModel = new Feedback.feedback_builder()
                   .setFeedback((String) feedbackDetails.get("feedback"))
                   .setStar(star)
                   .build();
           System.out.println("Feedback: " + feedbackDetails.get("feedback") + " Star: " + star);
           feedbackModel.addFeedback((String) feedbackDetails.get("feedback"),star);
           return ResponseEntity.ok("Feedback set successfully");
       }catch(Exception e){
           return ResponseEntity.badRequest().body("Failed to set feedback: " + e.getMessage());
       }
    }

    @RequestMapping("/getFeedback")
    public ResponseEntity<List<HashMap<String,Object>>> getFeedback() {
        try{
            Feedback _feedback = new Feedback();
            return ResponseEntity.ok(_feedback.getFeedback());
        }catch(Exception e){
            return ResponseEntity.badRequest().body(null);
        }
    }
}
