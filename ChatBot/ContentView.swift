//
//  ContentView.swift
//  Tester
//
//  Created by Niels Feijen on 20/03/2023.
//

//TODO:
// Re-ask question when answer is fucky
// Delete logs
// Siri combi?
// Custom behavior (like: doctor, professional, listmaker)


import OpenAISwift
import SwiftUI


final class ViewModel: ObservableObject{
    init(){}

    private var client: OpenAISwift?

    func setup(){
        client = OpenAISwift(authToken: "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")
    }

    func makeCall(text: String,
                  completion: @escaping (String) -> Void){
        client?.sendCompletion(with: text,
                               maxTokens: 500,
                               completionHandler: { result in
            print("Results: \(result)")
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                completion(output)
                print("Model: \(model)")
            case .failure:
                print("Failed: \(result)")
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()

    var body: some View {
        NavigationStack{
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(models, id: \.self){ string in
                            Text(string)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 10)

                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(10)
                .padding(.top, 0)

                HStack{
                    TextField("Type Here...", text: $text)
                    Button("Send"){
                        send()
                        text = ""
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding()

                .onAppear{
                    viewModel.setup()
                }
            }
            .navigationTitle("ChatBot")
        }

    }

    func send(){
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }

        models.append("Me: \(text)")
        models.append("")
        viewModel.makeCall(text: text){ response in
            DispatchQueue.main.async{
                self.models.append("ChatGPT: \(response)")
                self.models.append("")
                self.text = ""
            }

        }


    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
