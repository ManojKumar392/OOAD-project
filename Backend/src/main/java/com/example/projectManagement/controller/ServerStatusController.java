package com.example.projectManagement.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ServerStatusController {
    @RequestMapping("/")
    public String serverStatus(){
        return "✨ Server is up and running ✨";
        
    }
}