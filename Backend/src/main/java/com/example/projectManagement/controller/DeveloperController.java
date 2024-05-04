package com.example.projectManagement.controller;

import com.example.projectManagement.model.Developer;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;

@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping("/developer")
public class DeveloperController {
    final Developer _developer;
    DeveloperController(Developer developer) {
        this._developer = developer;
    }

    @RequestMapping("/viewProject")
    public void viewProject(@RequestBody HashMap<String,Object> data) {
        String userUID = (String) data.get("userUID");
       List<String> projects =  _developer.viewProject(userUID);
    }

    @RequestMapping("/reportWork")
    public void reportWork(@RequestBody HashMap<String,Object> data) {
        System.out.println("###################"+ data);
        try{
            String userUID = (String) data.get("userUID");
            String projectId = (String) data.get("projectId");
            String projectTitle = (String) data.get("Client");
            String description = (String) data.get("Description");
            double enteredHours = (double) data.get("Hours");
            String selectedWorkCategory = (String) data.get("Work");
            String userId = (String) data.get("userUID");
            String date = (String) data.get("Date");
            HashMap<String, Object> workCategories = (HashMap<String, Object>) data.get("workCategories");
            _developer.reportWork(userUID, projectId, projectTitle, description, enteredHours, selectedWorkCategory, userId,workCategories);
        }catch (Exception e){
            System.out.println("Error in reporting work" + e.getMessage());
        }
    }

    @RequestMapping("/getWorkedHours")
    public ResponseEntity<String> getWorkedHours(@RequestBody HashMap<String,Object> data) {
        try{
            String userUID = (String) data.get("userUID");
           String workedHours = String.valueOf(_developer.getWorkedHours(userUID));
            return ResponseEntity.ok().body(workedHours);
        }catch (Exception e){
            System.out.println("Error in getting work" + e.getMessage());
        }
        return null;
    }


}
