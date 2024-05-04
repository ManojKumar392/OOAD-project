package com.example.projectManagement.helperClasses;

import com.example.projectManagement.interfaces.RoleCommand;

import java.util.List;

public class Invoker {
    private RoleCommand command;

    public void setCommand(RoleCommand command) {
        this.command = command;
    }

    public String invoke(String name, String userUID, String email, String role, boolean isAdmin, boolean isActive, List<String> projectsAlloted,String github) {
        if (command != null) {
            return command.execute(name,userUID,email,role, isAdmin, isActive, projectsAlloted,github);
        }
        else {
            return null;
        }
    }
}
