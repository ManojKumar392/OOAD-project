package com.example.projectManagement.controller;
import com.example.projectManagement.enums.UserRole;
import com.example.projectManagement.model.User;
//import com.example.projectManagement.service.UserServiceImplementation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping("/user")
public class UserController {

    public final User _userModel;
    @Autowired
    public UserController(User _userModel) {
        this._userModel = _userModel;
    }
    @PostMapping("/create")
    public ResponseEntity<String> createUser(@RequestBody HashMap<String,Object> user) {
        try {
            System.out.println(user);
            String userUID = (String) user.get("userUID");
            String email = (String) user.get("email");
            String name = (String) user.get("name");
            Boolean isAdmin = (Boolean) user.get("isAdmin");
            Boolean isActive = (Boolean) user.get("isActive");
            List projectsAlloted = (List) user.get("projectsAlloted");
            String gitHubId = (String) user.get("gitHubId");
            String role = (String) user.get("role");
            String updateTime = _userModel.createUser(userUID, email, name,role, isAdmin, isActive, projectsAlloted, gitHubId);
            return ResponseEntity.ok("User created successfully at: " + updateTime);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to create user: " + e.getMessage());
        }
    }


    @GetMapping("/getAdminStatus")
    public ResponseEntity<?> getAdminStatus(@RequestParam String userUID) {
//        System.out.println("**********UserUID: " + userUID);
        try {
            Boolean isAdmin = _userModel.getAdminStatus(userUID);
            Map<String, Object> response = new HashMap<>();
            response.put("isAdmin", isAdmin);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity. badRequest().body("Failed to retrieve admin status: " + e.getMessage());
        }
    }
    @GetMapping("/getActiveStatus")
    public ResponseEntity<?> getActiveStatus(@RequestParam String userUID) {
//        System.out.println("**********UserUID: " + userUID);
        try {
            Boolean isAdmin = _userModel.getActiveStatus(userUID);
            Map<String, Object> response = new HashMap<>();
            response.put("isActive", isAdmin);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity. badRequest().body("Failed to retrieve admin status: " + e.getMessage());
        }
    }

    @GetMapping("/{userUID}")
    public ResponseEntity<?> getUser(@PathVariable String userUID) {
        try {
            Map<String,Object> user = _userModel.getUser(userUID);
            if (user != null) {
                   return ResponseEntity.ok(user);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to retrieve user: " + e.getMessage());
        }
    }

}
