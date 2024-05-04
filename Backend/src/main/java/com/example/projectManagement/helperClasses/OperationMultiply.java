package com.example.projectManagement.helperClasses;
import com.example.projectManagement.interfaces.Stratergy;
import org.springframework.stereotype.Service;

@Service
public class OperationMultiply implements Stratergy {
    public double doOperation(double num1, double num2) {
        double res = (num1 * num2);
        return res;
    }
}
