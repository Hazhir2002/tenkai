//
//  tenkai_widgetLiveActivity.swift
//  tenkai_widget
//
//  Created by Hazhir Yousefi on 7/14/1405 AP.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct tenkai_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct tenkai_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: tenkai_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension tenkai_widgetAttributes {
    fileprivate static var preview: tenkai_widgetAttributes {
        tenkai_widgetAttributes(name: "World")
    }
}

extension tenkai_widgetAttributes.ContentState {
    fileprivate static var smiley: tenkai_widgetAttributes.ContentState {
        tenkai_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: tenkai_widgetAttributes.ContentState {
         tenkai_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: tenkai_widgetAttributes.preview) {
   tenkai_widgetLiveActivity()
} contentStates: {
    tenkai_widgetAttributes.ContentState.smiley
    tenkai_widgetAttributes.ContentState.starEyes
}
