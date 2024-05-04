package com.example.projectManagement.controller;

import com.example.projectManagement.model.Work;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;

@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping("/work")
public class WorkController {
    public Work _work;
    public WorkController(Work work) {
        this._work = work;
    }

    @RequestMapping("/getReportedWork")
    public ResponseEntity<List<HashMap<String, Object>>> getReportedWork( ) {
      List<HashMap<String,Object>> reportedWork = _work.getReportedWork();
        return ResponseEntity.ok(reportedWork
        );
    }

}
