package com.example.projectManagement.ProxyClass;

import com.example.projectManagement.model.User;
import org.springframework.boot.autoconfigure.security.SecurityProperties;
import org.springframework.stereotype.Service;

@Service
public class ProtectionProxy {

    private User _user;

    public ProtectionProxy(User userManager) {
        this._user = userManager;
    }

    public boolean hasPermissionToDeactivate(String userUID) throws Exception {
       try{
           Boolean adminStatus = _user.getAdminStatus(userUID);
           return adminStatus != null && adminStatus;
       }catch (Exception e){
           throw new Exception("Error in checking permission: " + e.getMessage());
       }
    }
}
