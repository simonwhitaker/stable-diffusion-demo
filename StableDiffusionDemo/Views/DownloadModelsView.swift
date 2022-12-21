//
//  DownloadModelsView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 20/12/2022.
//

import SwiftUI
import Light_Swift_Untar

struct DownloadModelsView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var isDownloading = false

    var body: some View {
        return HStack {
            Button {
                Task {
                    do {
                        isDownloading = true
                        try await downloadModels()
                        modelData.hasLocalModels = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Download models")
            }.disabled(isDownloading)
        }.padding()
    }
}

struct DownloadModelsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadModelsView()
    }
}
