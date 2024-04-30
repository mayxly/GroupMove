import SwiftUI

struct GridPicker<Data, Label, Content>: View where Data: RandomAccessCollection, Data.Index == Int, Data.Element: Hashable, Data.Element: Identifiable, Label: View, Content: View {

  @Environment(\.gridPickerStyle) private var pickerStyle

  typealias SelectionValue = Data.Element

  let data: Data
  let selection: Binding<SelectionValue>
  let label: Label
  let content: (Data.Element) -> Content

  @State private var isContentActive: Bool = false

  init(_ data: Data, selection: Binding<SelectionValue>, label: Label, @ViewBuilder content: @escaping (SelectionValue) -> Content) {
    self.data = data
    self.selection = selection
    self.label = label
    self.content = content
  }

  var body: some View {
        Group {
          GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
              ForEach(0..<self.numberOfRows) { row in
                HStack(spacing: 0) {
                  ForEach(self.items(at: row), id: \.self) { emoji in
                    Button(action: {
                      self.selection.wrappedValue = emoji
                      self.isContentActive = false
                    }) {
                      self.content(emoji)
                    }
                    .frame(width: self.sizeOfItem(in: proxy).width, height: self.sizeOfItem(in: proxy).height)
                  }
                }
              }
              Spacer()
            }
          }
          .navigationBarTitle(pickerStyle.title)
          .padding()
        }
  }

  private var numberOfRows: Int {
    if data.count % pickerStyle.columns == 0 {
      return data.count / pickerStyle.columns
    } else {
      return data.count / pickerStyle.columns + 1
    }
  }


  private func items(at row: Int) -> Data.SubSequence {
    if row < numberOfRows - 1 {
      return data[pickerStyle.columns * row ..< pickerStyle.columns * row + pickerStyle.columns]
    } else if row == numberOfRows - 1 {
      return data[pickerStyle.columns * row ..< pickerStyle.columns * row + data.count % pickerStyle.columns]
    } else {
      fatalError("row out of bounds")
    }
  }

  private func sizeOfItem(in geo: GeometryProxy) -> CGSize {
    let width = geo.size.width / CGFloat(pickerStyle.columns)
    return CGSize(width: width, height: width)
  }
}

protocol GridPickerStyle {
  var title: String { get }
  var columns: Int { get }
}

struct DefaultGridPickerStyle: GridPickerStyle {
  let title: String
  let columns: Int

  init(title: String = "Grid Picker", columns: Int = 5) {
    self.title = title
    self.columns = columns
  }
}

struct GridPickerStyleKey: EnvironmentKey {
  static let defaultValue: GridPickerStyle = DefaultGridPickerStyle()
}

extension EnvironmentValues {
  var gridPickerStyle: GridPickerStyle {
    get {
      return self[GridPickerStyleKey.self]
    }
    set {
      self[GridPickerStyleKey.self] = newValue
    }
  }
}

extension View {
  func gridPickerStyle<Style>(_ style: Style) -> some View where Style : GridPickerStyle {
    self.environment(\.gridPickerStyle, style)
  }
}

extension String: Identifiable {
  public var id: String { self }
}
//
//struct ContentView: View {
//  @State var selection: String = "🍎"
//  let emojis = [
//    "🍎", "🍌", "🍇", "🍐", "🍒", "🍑",
//    "😀", "🥶", "🥺", "🤥", "🤢", "🤤",
//    "🐶", "🐭", "🐣", "🙉", "🐸", "🦄",
//    "⚽️", "🏀", "⚾️", "🥎", "🏐", "🎱",
//  ]
//  var body: some View {
//    NavigationView {
//      Form {
//        HStack {
//          GridPicker(emojis, selection: $selection, label: Text("Emoji")) {
//            Text($0)
//          }
//          .gridPickerStyle(DefaultGridPickerStyle(title: "Emoji Picker"))
//        }
//      }
//      .navigationBarTitle("Fuck Picker")
//    }
//  }
//}
//
//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView()
//  }
//}
