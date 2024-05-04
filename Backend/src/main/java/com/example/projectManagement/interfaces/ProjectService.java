package com.example.projectManagement.interfaces;

import java.util.List;
import java.util.Map;

public interface ProjectService
{
    public List<Map<String,Object>> getAllDevelopers();
    public void createProject(Map<String,Object> projectDetails);

    public String updateProject();
    public String getProjectById(String projectId);
    public String getAllProjects();
    public String getProjectsByDeveloper(String userId);

}
