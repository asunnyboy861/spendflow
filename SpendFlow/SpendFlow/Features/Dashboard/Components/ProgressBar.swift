import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let color: Color
    let height: CGFloat

    init(progress: Double, color: Color = .accentBlue, height: CGFloat = 8) {
        self.progress = progress
        self.color = color
        self.height = height
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(color.gradient)
                    .frame(width: geometry.size.width * min(progress, 1.0), height: height)
                    .animation(.spring(response: 0.5), value: progress)
            }
        }
        .frame(height: height)
    }
}
