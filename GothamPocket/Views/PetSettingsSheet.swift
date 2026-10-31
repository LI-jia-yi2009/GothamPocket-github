import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var store: PetStore
    @Environment(\.dismiss) private var dismiss

    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $store.rainEnabled) {
                        Label("雨夜模式", systemImage: "cloud.rain.fill")
                    }

                    Toggle(isOn: $store.effectsEnabled) {
                        Label("粒子特效", systemImage: "sparkles")
                    }

                    Toggle(isOn: $store.hapticsEnabled) {
                        Label("触感反馈", systemImage: "iphone.radiowaves.left.and.right")
                    }
                } header: {
                    Text("屋顶")
                }

                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("重置心情", systemImage: "arrow.counterclockwise")
                    }
                }

                Section {
                    Text("非官方同人作品。蝙蝠侠与小丑的版权归 DC Comics 所有。")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.secondary)
                } header: {
                    Text("关于")
                }
            }
            .scrollContentBackground(.hidden)
            .background(GothamTheme.ink)
            .navigationTitle("屋顶设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .fontWeight(.semibold)
                        .tint(store.companion.accent)
                }
            }
            .tint(store.companion.accent)
            .preferredColorScheme(.dark)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .alert("重置心情？", isPresented: $showResetConfirmation) {
            Button("取消", role: .cancel) {}
            Button("重置", role: .destructive) {
                store.resetMood()
            }
        } message: {
            Text("当前心情会回到 58。")
        }
    }
}
