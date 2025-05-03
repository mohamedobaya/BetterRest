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
    
    var bedTime: String {
        var message = ""
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 3600
            let minute  = (components.minute ?? 0) * 60
            
            let predection = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - predection.actualSleep
   
            message = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            message = "Sorry, there was a problem calculating your bedtime."
        }
        return message
    }

    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a date?", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section("Daily coffee intake") {
//                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)

                    Picker("Daily coffee intake", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                    
                    // ^[some String](inflect: true) add "s" if the string plural according to the coffeeAmount variable
                }
                Section("↓ Your idle sleep time is ↓") {
                    Text("\(bedTime)")
                }
            }
            .navigationTitle("BetterRest ⏾")
        }
    }
}

#Preview {
    ContentView()
}
