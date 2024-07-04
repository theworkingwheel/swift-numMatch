import SwiftUI

struct ContentView: View {
    @State private var numbers = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5].shuffled()
    @State private var selectedIndices: [Int] = []
    @State private var matchedIndices: [Int] = []
    @State private var timerCount = 0
    @State private var isTimerRunning = true
    @State private var finalTime = 0
    @State private var bestTime = Int.max
    
    var body: some View {
        VStack {
            Text("Match the Numbers!")
                .font(.largeTitle)
                .padding()
            
            Text("Time: \(timerCount) seconds")
                .font(.title2)
                .padding()
            
            if bestTime != Int.max {
                Text("Best Time: \(bestTime) seconds")
                    .font(.title2)
                    .padding()
            }
            
            GridView(numbers: $numbers, selectedIndices: $selectedIndices, matchedIndices: $matchedIndices)
                .padding()
            
            Spacer()
            
            if matchedIndices.count == numbers.count {
                VStack {
                    Text("You Win!")
                        .font(.largeTitle)
                        .padding()
                    Text("Time Taken: \(finalTime) seconds")
                        .font(.title2)
                        .padding()
                    
                    Button(action: restartGame) {
                        Text("Restart Game")
                            .font(.title2)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .onAppear {
                    isTimerRunning = false
                    if finalTime < bestTime {
                        bestTime = finalTime
                    }
                }
            }
        }
        .padding()
        .onAppear {
            startTimer()
        }
        .onChange(of: matchedIndices.count) { newValue in
            if newValue == numbers.count {
                finalTime = timerCount
                isTimerRunning = false
            }
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.isTimerRunning {
                self.timerCount += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func restartGame() {
        numbers = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5].shuffled()
        selectedIndices = []
        matchedIndices = []
        timerCount = 0
        finalTime = 0
        isTimerRunning = true
        startTimer()
    }
}

struct GridView: View {
    @Binding var numbers: [Int]
    @Binding var selectedIndices: [Int]
    @Binding var matchedIndices: [Int]
    
    let columns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(numbers.indices, id: \.self) { index in
                CardView(number: numbers[index], isFlipped: selectedIndices.contains(index) || matchedIndices.contains(index), isMatched: matchedIndices.contains(index))
                    .onTapGesture {
                        cardTapped(index: index)
                    }
            }
        }
    }
    
    private func cardTapped(index: Int) {
        if selectedIndices.count == 2 {
            selectedIndices = []
        }
        
        if !selectedIndices.contains(index) && !matchedIndices.contains(index) {
            selectedIndices.append(index)
            
            if selectedIndices.count == 2 {
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        if numbers[selectedIndices[0]] == numbers[selectedIndices[1]] {
            matchedIndices.append(contentsOf: selectedIndices)
            selectedIndices = []
        }
    }
}


struct CardView: View {
    let number: Int
    let isFlipped: Bool
    let isMatched: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isMatched ? Color.green : (isFlipped ? Color.blue : Color.gray))
                .frame(width: 50, height: 50)
            
            if isFlipped || isMatched {
                Text("\(number)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
    }
}



