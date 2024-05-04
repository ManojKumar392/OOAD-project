package com.example.projectManagement.interfaces;

import com.example.projectManagement.enums.UserRole;

import java.util.List;

public interface RoleCommand {
    String execute(String name, String userUID, String email, String role, boolean isAdmin, boolean isActive, List<String> projectsAlloted,String github);
}
