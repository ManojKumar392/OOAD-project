package com.example.projectManagement.interfaces;
import com.example.projectManagement.enums.UserRole;
import com.example.projectManagement.model.User;

import java.util.List;
import java.util.Map;

public interface UserService {

    String createUser(String userUID, String email, String password, UserRole role,Boolean isAdmin, Boolean isActive, List projectsAlloted, String github) throws Exception;
    Map getUser(String id) throws Exception;

    Boolean getAdminStatus(String userUID) throws Exception;
    String deleteUser(String id) throws Exception;
    String authenticateUsingGoogleAuth() throws Exception;

    Boolean getActiveStatus(String userUID) throws Exception;
}

