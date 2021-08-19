//
//  LocalConfigFile.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 15/08/2021.
//

import Foundation
import SwiftkubeClient
import Yams
import Logging
import SwiftUI
import UniformTypeIdentifiers


struct OpenConfigFileButton: View {
    var types = [UTType]()
    @State var fileString:String? = nil
    let successfulParseOfFileCallback: (_ config: KubernetesClientConfig) -> Void
    init(cb: @escaping (_ config: KubernetesClientConfig) -> Void) {
        self.successfulParseOfFileCallback = cb
        types.append(UTType(filenameExtension: "yaml")!)
    }
    var body: some View {
        VStack{
            if let fs = fileString {
                Text(fs).italic()
            }
            HStack{
                Button("Open", action: openFile)
                if let fs = fileString {
                    Button("Parse"){
                        print("not implemented")
                        let client123 = try! KubernetesClient.loadConfigFromPath(logger: Logger(label: "SKC-do-not-log", factory: { _ in SwiftLogNoOpLogHandler() }), path: fs)
                        if let client = client123 {
                            successfulParseOfFileCallback(client)
                        }
                    }
                }

            }
        }
    }
    func openFile() -> Void {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = types
        if panel.runModal() == .OK {
            print(panel.url?.path ?? "<none>")
            if let u = panel.url {
                self.fileString = u.path
            }
            
        }
    }
}
