//
//  ContentView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 14/12/2022.
//

import SwiftUI
import StableDiffusion

struct ContentView: View {
    @State private var prompt: String = "A photo of a kitten on the moon"
    @State private var image: CGImage? = nil
    @State private var currentStep: Int? = nil
    @State private var pipeline: StableDiffusionPipeline? = nil
    @EnvironmentObject var modelData: ModelData

    let NumSteps = 3

    var body: some View {
        VStack {
            Text("Stable Diffusion Demo").font(.title)

            if modelData.hasCachedModels {
                HStack {
                    TextField("Prompt:", text: $prompt)
                    Button(
                        action: {
                            print("Calling stable diffusion with prompt: \"\(prompt)\"")

                            currentStep = 0
                            DispatchQueue.global(qos:.background).async {
                                var newImage: CGImage?
                                do {
                                    newImage = try pipeline!.generateImages(prompt:prompt, stepCount: NumSteps, progressHandler: { progress in
                                        print("Step \(progress.step) of \(progress.stepCount)")
                                        DispatchQueue.main.async {
                                            currentStep = progress.step
                                        }
                                        return true
                                    }).first!

                                    DispatchQueue.main.async {
                                        image = newImage
                                        currentStep = nil
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        print("There was an error: \(error)")
                                        currentStep = nil
                                    }
                                }
                            }
                        },
                        label: {
                            Text("Go")
                        }
                    ).disabled(currentStep != nil || pipeline == nil)
                }.onAppear {
                    var _pipeline: StableDiffusionPipeline? = nil
                    DispatchQueue.global().async {
                        do {
                            print("Loading pipeline...")
                            _pipeline = try StableDiffusionPipeline(resourcesAt: modelData.cachedModelsUrl, disableSafety: true)
                            DispatchQueue.main.async {
                                // TODO: check if you can set state vars from a background thread
                                pipeline = _pipeline
                            }
                        } catch {
                            print("Error loading pipeline: \(error)")
                        }
                    }
                }


                if currentStep != nil {
                    ProgressView(value: Float(currentStep!), total: Float(NumSteps)) {
                        Text("Step \(currentStep! + 1) of \(NumSteps)").font(.caption)
                    }
                }

                if image != nil {
                    Image(image!, scale: 1.0, label: Text(verbatim: ""))
                }

                Spacer()
            } else {
                DownloadModelsView()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ModelData())
    }
}
