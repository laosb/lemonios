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

struct newFuncRow: View {
//    var street: Street
    @State var versionContent: LMNewFuncGuideVersionContent
    var body: some View {
        VStack(alignment: .leading) {
            Text("v\(versionContent.version) ")
                .font(.title)
                .padding(.bottom)
            VStack (alignment: .leading, spacing: 7.0) {
                ForEach(versionContent.content, id: \.self) { row in
                    Text(row)
                }
            }
        }.padding(.vertical)
    }
}

struct newFuncRow_Previews: PreviewProvider {
    static var previews: some View {
        newFuncRow(versionContent: LMNewFuncGuideVersionContent(version: "1.0", content: ["c1","c2"]))
    }
}
