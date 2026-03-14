import SwiftUI

struct SettingsView: View {
    @State private var numeralStyle: NumeralStyle = SharedStore.shared.numeralStyle
    @State private var fontIsSerif: Bool = SharedStore.shared.fontIsSerif
    @State private var fontSizeOption: FontSizeOption = SharedStore.shared.fontSizeOption

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            List {
                Section {
                    HStack {
                        Text("Numerals")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("", selection: $numeralStyle) {
                            ForEach(NumeralStyle.allCases, id: \.self) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    HStack {
                        Text("Font")
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("Serif", isOn: $fontIsSerif)
                            .labelsHidden()
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    HStack {
                        Text("Size")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("", selection: $fontSizeOption) {
                            ForEach(FontSizeOption.allCases, id: \.self) { size in
                                Text(size.displayName).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                    .listRowBackground(Color.white.opacity(0.06))
                } header: {
                    Text("Display")
                        .foregroundColor(.white.opacity(0.4))
                        .textCase(.uppercase)
                        .font(.system(.caption, design: .default))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .onChange(of: numeralStyle) {
            SharedStore.shared.numeralStyle = $0
            PhoneSessionManager.shared.sendSettings(numeralStyle: $0, fontIsSerif: fontIsSerif, fontSizeOption: fontSizeOption)
        }
        .onChange(of: fontIsSerif) {
            SharedStore.shared.fontIsSerif = $0
            PhoneSessionManager.shared.sendSettings(numeralStyle: numeralStyle, fontIsSerif: $0, fontSizeOption: fontSizeOption)
        }
        .onChange(of: fontSizeOption) {
            SharedStore.shared.fontSizeOption = $0
            PhoneSessionManager.shared.sendSettings(numeralStyle: numeralStyle, fontIsSerif: fontIsSerif, fontSizeOption: $0)
        }
    }
}
