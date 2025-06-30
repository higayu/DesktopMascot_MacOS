//
//  MascotView.swift
//  DesktopMascot
//
//  Created by 東山友輔 on 2025/07/01.
//
import SwiftUI
import AppKit

enum UsamaruMode {
    case stop, patoka, walk, hiyokoGyu, popCone, cry, sleep, cheerleader, amaenbo, kanpe, yorokobi
}

struct MascotView: View {
    @EnvironmentObject var viewModel: MascotViewModel
    
    var body: some View {
        Group {
            if viewModel.mode == .patoka {
                // パトカーモードではGIFアニメーションを使用
                GIFView(gifName: viewModel.mascotImage)
                    .frame(width: 200, height: 200)
            } else {
                // ストップモードでは通常の画像を使用
                Image(viewModel.mascotImage)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .onAppear {
                        print("MascotView appeared with image: \(viewModel.mascotImage)")
                        // 画像が見つからない場合のフォールバック
                        if NSImage(named: viewModel.mascotImage) == nil {
                            print("Image \(viewModel.mascotImage) not found, falling back to system icon")
                            viewModel.mascotImage = "NSApplicationIcon"
                        }
                    }
            }
        }
        .position(viewModel.mascotPosition) // マスコットはウィンドウ内で固定位置
        .onTapGesture {
            viewModel.handleTap()
        }
        .onHover { inside in
            // hover時のアクションなど
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // ウィンドウ全体を移動
                    let newWindowPosition = CGPoint(
                        x: viewModel.windowPosition.x + value.translation.width,
                        y: viewModel.windowPosition.y + value.translation.height
                    )
                    viewModel.windowPosition = newWindowPosition
                    viewModel.updateWindowPosition()
                }
        )
        .background(Color.clear)
        .contextMenu {
            Button("ストップ") {
                viewModel.stopImageChange()
            }
            Button("パトカー") {
                viewModel.patokaChange()
            }
            Divider()
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
        .onAppear {
            setupWindow()
        }
    }
    
    private func setupWindow() {
        // ウィンドウの設定を適用
        if let window = NSApplication.shared.windows.first {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.level = .floating
            window.ignoresMouseEvents = false
            window.isMovableByWindowBackground = true
            window.acceptsMouseMovedEvents = true
        }
    }
}
