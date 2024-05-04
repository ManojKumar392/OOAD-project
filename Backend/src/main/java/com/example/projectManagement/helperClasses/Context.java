package com.example.projectManagement.helperClasses;


import com.example.projectManagement.interfaces.Stratergy;

public class Context {
        private Stratergy strategy;

        public Context(Stratergy strategy) {
            this.strategy = strategy;
        }

        public double executeStrategy(double num1, double num2) {
           return strategy.doOperation(num1, num2);
        }
    }

