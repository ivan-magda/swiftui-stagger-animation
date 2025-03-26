#if DEBUG
import SwiftUI

struct MyColor: Identifiable {
    var id = UUID()
    var color: Color
}

let sampleColors = (0..<10).map { ix in
    MyColor(color: .init(hue: .init(ix) / 20, saturation: 0.8, brightness: 0.8))
}

@available(iOS 16.0, *)
struct ContentView: View {
    @State private var colors = sampleColors

    var body: some View {
        let rect = RoundedRectangle(cornerRadius: 16)
        VStack(spacing: 16) {
            rect.fill(.blue.gradient)
                .frame(height: 120)
                .stagger(
                    transition: .move(edge: .top).combined(with: .opacity),
                    priority: -1
                )

            LazyVGrid(columns: [.init(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                ForEach(colors) { color in
                    rect.fill(color.color.gradient)
                        .frame(height: 80)
                        .stagger(transition: .scale.combined(with: .opacity))
                }
            }

            Button("Add") {
                for _ in 0..<5 {
                    colors.append(.init(color: Color(hue: .random(in: 0...1), saturation: 0.6, brightness: 0.6)))
                }
            }
        }
        .padding()
        .staggerContainer()
    }
}

@available(iOS 16.0, *)
#Preview {
    ContentView()
}
#endif
