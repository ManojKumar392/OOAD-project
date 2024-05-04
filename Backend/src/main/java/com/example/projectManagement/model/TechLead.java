package com.example.projectManagement.model;

import com.example.projectManagement.enums.UserRole;

/**
 * TechLead class extends User class and represents a technical lead in the project management system.
 * It provides methods for planning architecture, reviewing tasks, viewing tasks and projects, creating components, setting max hours, and updating projects.
 */

public class TechLead extends User {
    public TechLead(String name, String userUID, String email) {
        super(name, userUID, email, "");
    }

    public void planArchitecture(){
        System.out.println("Task assigned");
    }

    public void reviewTask(){
        System.out.println("Task reviewed");
    }

    public void viewTask(){
        System.out.println("Task viewed");
    }

    public void createComponentsAndSetMaxHours(){
        System.out.println("Task created");
    }

    public void viewProject(){
        System.out.println("Project viewed");
    }

    public void updateProject(){
        System.out.println("Project updated");
    }

}
