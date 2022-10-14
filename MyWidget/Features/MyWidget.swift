//
//  MyWidget.swift
//  MyWidget
//
//  Created by Vladyslav Lysenko on 11.10.2022.
//

import WidgetKit
import SwiftUI
import Intents
import Combine
import Services

struct MyWidgetEntryView: View {
    private var entry: MyWidgetVM.Entry
    
    init(entry: MyWidgetVM.Entry) {
        self.entry = entry
    }

    var body: some View {
        Text(entry.text)
    }
}

@main
struct MyWidget: Widget {
    let platform = Platform()
    let kind: String = "MyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ConfigurationIntent.self,
                            provider: MyWidgetVM(useCases: platform)) { entry in
            MyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyWidgetEntryView(entry: SimpleEntry(date: Date(),text: "Text", configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
