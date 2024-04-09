import SwiftUI
import PixelColor

public struct GradientView: View {
    
    static let length: CGFloat = 44
    static let addThresholdDistance: CGFloat = 0.2
    
    @Binding var colorStops: [GradientColorStop]
    
    let edit: (Bool) -> ()
    
    public init(
        colorStops: Binding<[GradientColorStop]>,
        edit: @escaping (Bool) -> () = { _ in }
    ) {
        _colorStops = colorStops
        self.edit = edit
    }
    
    @State private var dragStart: (index: Int, location: CGFloat)?
    
    var indexStops: [(index: Int, stop: GradientColorStop)] {
        Array(colorStops.enumerated())
            .sorted(by: { $0.element.location < $1.element.location })
            .map { index, stop in
                (index: index, stop: stop)
            }
    }
    
    private var stops: [Gradient.Stop] {
        indexStops.map(\.stop).map { stop in
            Gradient.Stop(color: stop.color.color, location: stop.location)
        }
    }
    
    public var body: some View {
        
        GeometryReader { proxy in
            
            ZStack {
                
                /// Gradient
                Capsule()
                    .fill(LinearGradient(
                        stops: stops,
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: Self.length)
                
                VStack(spacing: 0) {
                    
                    /// Color Stop
                    ZStack(alignment: .leading) {
                        Color.clear
                        ForEach(Array($colorStops.enumerated()), id: \.offset) { index, stop in
                            colorStop(stop, at: index, size: proxy.size)
                                .offset(
                                    x: stop.location.wrappedValue * (proxy.size.width - Self.length)
                                )
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        Color.clear
                        
                        /// Add First
                        if let firstIndexStop = indexStops.first {
                            let distance: CGFloat = firstIndexStop.stop.location
                            if distance > Self.addThresholdDistance {
                                addButton(at: 0, newStop: GradientColorStop(at: 0.0, color: firstIndexStop.stop.color))
                            }
                        }
                        
                        /// Add
                        ForEach(Array(indexStops.dropLast().enumerated()), id: \.offset) { index, indexStop in
                            let nextIndex: Int = index + 1
                            if indexStops.indices.contains(nextIndex) {
                                let nextIndexStop = indexStops[nextIndex]
                                let newLocation: CGFloat = (indexStop.stop.location + nextIndexStop.stop.location) / 2
                                let distance: CGFloat = abs(indexStop.stop.location - nextIndexStop.stop.location)
                                if distance > Self.addThresholdDistance {
                                    addButton(at: indexStop.index, between: (leading: indexStop.stop, trailing: nextIndexStop.stop))
                                        .offset(
                                            x: newLocation * (proxy.size.width - Self.length)
                                        )
                                }
                            }
                        }
                        
                        /// Add Last
                        if let lastIndexStop = indexStops.last {
                            let distance: CGFloat = 1.0 - lastIndexStop.stop.location
                            if distance > Self.addThresholdDistance {
                                addButton(at: lastIndexStop.index + 1, newStop: GradientColorStop(at: 1.0, color: lastIndexStop.stop.color))
                                    .offset(x: proxy.size.width - Self.length)
                            }
                        }
                        
                        /// Remove
                        if colorStops.count > 2 {
                            ForEach(Array(colorStops.enumerated()), id: \.offset) { index, stop in
                                removeButton(at: index)
                                    .offset(
                                        x: stop.location * (proxy.size.width - Self.length)
                                    )
                            }
                        }
                    }
                    .frame(height: Self.length)
                }
            }
        }
        .frame(height: Self.length * 3)
    }
    
    @ViewBuilder
    private func addButton(
        at index: Int,
        between colorStops: (leading: GradientColorStop, trailing: GradientColorStop)
    ) -> some View {
        let newLocation: CGFloat = (colorStops.leading.location + colorStops.trailing.location) / 2
        let newColor: PixelColor = (colorStops.leading.color + colorStops.trailing.color) / 2
        let newStop = GradientColorStop(at: newLocation, color: newColor)
        addButton(at: index, newStop: newStop)
    }
    
    private func addButton(
        at index: Int,
        newStop: GradientColorStop
    ) -> some View {
        button {
            colorStops.insert(newStop, at: index + 1)
        } label: {
            Image(systemName: "plus")
        }
        .foregroundStyle(.blue)
    }
    
    private func removeButton(
        at index: Int
    ) -> some View {
        button {
            colorStops.remove(at: index)
        } label: {
            Image(systemName: "minus")
        }
        .foregroundStyle(.red)
    }
    
    private func button<Label: View>(
        action: @escaping () -> (),
        label: () -> Label
    ) -> some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .opacity(0.2)
                label()
            }
            .padding(8)
            .frame(width: Self.length, height: Self.length)
        }
        .buttonStyle(.plain)
    }
    
    private func colorStop(
        _ stop: Binding<GradientColorStop>,
        at index: Int,
        size: CGSize
    ) -> some View {
        VStack(spacing: 0) {
            ColorPicker(selection: .init(get: {
                stop.wrappedValue.color.color
            }, set: { newColor in
                edit(true)
                stop.wrappedValue.color = .init(newColor)
                edit(false)
            })) {
                EmptyView()
            }
            .labelsHidden()
            .frame(height: Self.length)
            
            ZStack {
                Color.gray.opacity(0.001)
                HStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        ZStack {
                            Capsule()
                                .stroke(lineWidth: 2)
                                .colorInvert()
                            Capsule()
                        }
                        .frame(width: 3)
                        .compositingGroup()
                        .opacity(0.25)
                    }
                }
                .padding(.vertical, 11)
            }
            .frame(width: Self.length,
                   height: Self.length)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if dragStart == nil {
                            dragStart = (index: index, location: stop.wrappedValue.location)
                            edit(true)
                        }
                        var location: CGFloat = dragStart!.location + value.translation.width / size.width
                        location = min(max(location, 0.0), 1.0)
                        stop.wrappedValue.location = location
                    }
                    .onEnded { _ in
                        dragStart = nil
                        edit(false)
                    }
            )
        }
        .frame(width: Self.length)
    }
}

struct GradientPreview: View {
    
    @State private var gradients: [GradientColorStop] = [
        .init(at: 0.0, color: .blue),
        .init(at: 1.0, color: .yellow)
    ]
    
    var body: some View {
        GradientView(
            colorStops: $gradients,
            edit: { _ in }
        )
    }
}

#Preview {
    GradientPreview()
}
