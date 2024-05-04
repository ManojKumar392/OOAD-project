package com.example.projectManagement.controller;

import com.example.projectManagement.ProxyClass.ProtectionProxy;
import com.example.projectManagement.model.ProjectManager;
import com.example.projectManagement.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutionException;

@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping("/project")
public class ProjectController
{
    final ProjectManager _projectManager;
    final User _user;
    final ProtectionProxy _protectionProxy;

    public ProjectController(ProjectManager projectManager,User user,ProtectionProxy protectionProxy) {
        this._projectManager = projectManager;
        this._user = user;
        this._protectionProxy = protectionProxy;
    }

    @Autowired
    private ApplicationContext context;

    @RequestMapping("/create")
    public ResponseEntity<String> createProject(@RequestBody HashMap<String,Object> projectDetails)
    {

        System.out.println("###################");
        System.out.println("Received data: " + projectDetails);
        try {
            _projectManager.createProject(projectDetails);
            return ResponseEntity.ok("Project created successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to create project: " + e.getMessage());
        }
    }

    @RequestMapping("/deactivate")
    public ResponseEntity<String> deactivateProject(@RequestBody HashMap<String,Object> data) throws Exception {
      try{
          ProtectionProxy protectionProxy = context.getBean(ProtectionProxy.class,_user);
          String userUID = (String) data.get("userUID");
          boolean adminStatus = protectionProxy.hasPermissionToDeactivate(userUID);
          if(!adminStatus){
                return ResponseEntity.ok("You are not authorized to delete project");
            }
          _projectManager.deactivateProject((String) data.get("projectId"), (String) data.get("userUID"));
          return ResponseEntity.ok("Project deleted successfully");
      }catch(Exception e){
          return ResponseEntity.ok("Failed to delete project: " + e.getMessage());
      }
    }

    @RequestMapping("/update")
    public ResponseEntity<String> updateProject(@RequestBody HashMap<String,Object> updatedProjectDetails)
    {
        System.out.println("###################" + updatedProjectDetails);
        _projectManager.updateProject(updatedProjectDetails);
        return ResponseEntity.ok("Project updated successfully");
    }

    @RequestMapping("/getAll")
    public ResponseEntity<List<HashMap<String,Object>>> getAllProjects() {
        System.out.println("############ Called Get All projects");
        try {
            final List<HashMap<String, Object>> projects = _projectManager.getAllProjects();
            return ResponseEntity.ok().body(projects);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    @RequestMapping("/getByUser")
    public String getProjectsByUser(@RequestBody String userId)
    {
        return "Projects retrieved successfully by user";
    }

    @RequestMapping("/assignDeveloper")
    public ResponseEntity<String> assignDeveloperToProject(@RequestBody HashMap<String, String> data)
    {
        try {
            _projectManager.addDevelopersToProject(data.get("projectId"), data.get("userUID"));
            return ResponseEntity.ok("Developer assigned to project successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to assign developer to project: " + e.getMessage());
        }
    }

    @RequestMapping("/getByProjectId")
    public ResponseEntity< HashMap<String,Object>> getProjectsByProjectId(@RequestBody HashMap<String,Object> data)
    {
        String projectId = (String) data.get("projectId");
        HashMap<String,Object> project = _projectManager.getByProjectId(projectId);
        System.out.println("Project retrieved successfully" + project);
        return ResponseEntity.ok().body(project);
    }

}
