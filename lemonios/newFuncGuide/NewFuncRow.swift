//
//  newFuncRow.swift
//  lemonios
//
//  Created by ljz on 2019/11/12.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

//struct Street: Identifiable {
//    var id = UUID()
//    var title: String
//    var content: String
//}

struct LMNewFuncGuideVersionContent {
    var version: String
    var content: [String]
    
}

struct NewFuncRow: View {
//    var street: Street
    @State var versionContent: LMNewFuncGuideVersionContent
    var body: some View {
        VStack(alignment: .leading) {
            Text("v\(versionContent.version) ")
                .font(.title)
                .padding(.bottom)
            VStack (alignment: .leading, spacing: 7.0) {
                #if targetEnvironment(macCatalyst)
                ForEach(self.versionContent.content.filter{ line in
                    return !line.hasPrefix("[NOMAC]")
                }.map{ line in
                    return line.replacingOccurrences(of: "[MACONLY]", with: "")
                }, id: \.self) { row in
                    Text(row)
                }
                #else
                ForEach(self.versionContent.content.map{ line in
                    return line.replacingOccurrences(of: "[NOMAC]", with: "")
                }.filter{ line in
                    return !line.hasPrefix("[MACONLY]")
                }, id: \.self) { row in
                    Text(row)
                }
                #endif
            }
        }.padding(.vertical)
    }
}

struct NewFuncRow_Previews: PreviewProvider {
    static var previews: some View {
        NewFuncRow(versionContent: LMNewFuncGuideVersionContent(version: "1.0", content: ["c1","c2"]))
    }
}
