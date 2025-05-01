//
//  ContentView.swift
//  BetterRest
//
//  Created by Mohamed Obaya on 30/04/2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var defaultWakeTime: Date {
        var compenents = DateComponents()
        compenents.hour = 7
        compenents.minute = 0
        return Calendar.current.date(from: compenents) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a date?", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                    // ^[some String](inflect: true) add "s" if the string plural according to the coffeeAmount variable
                }
            }
            .navigationTitle("BetterRest ⏾")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {
                    // does nothing
                }
            } message: {
                Text("\(alertMessage)")
            }
        }
        
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 3600
            let minute  = (components.minute ?? 0) * 60
            
            let predection = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - predection.actualSleep
   
            alertTitle = "Your idle bed time is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
//            print(alertMessage)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showAlert = true
    }
}

#Preview {
    ContentView()
}
