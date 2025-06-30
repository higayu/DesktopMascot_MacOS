//
//  GIFView.swift
//  DesktopMascot
//
//  Created by 東山友輔 on 2025/07/01.
//

import SwiftUI
import AppKit
import ImageIO

struct GIFView: NSViewRepresentable {
    let gifName: String

    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageFrameStyle = .none
        imageView.wantsLayer = true
        imageView.layer?.backgroundColor = NSColor.clear.cgColor
        imageView.imageAlignment = .alignCenter // 画像を中央に配置
        
        loadGif(imageView: imageView, name: gifName, coordinator: context.coordinator)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
        // GIF名が変更された場合のみ再読み込み
        if let currentGif = context.coordinator.currentGifName, currentGif != gifName {
            loadGif(imageView: nsView, name: gifName, coordinator: context.coordinator)
            context.coordinator.currentGifName = gifName
        }
    }
    
    private func loadGif(imageView: NSImageView, name: String, coordinator: Coordinator) {
        DispatchQueue.global(qos: .userInitiated).async {
            // ResourcesフォルダからGIFファイルを読み込み
            guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
                print("GIF named \(name) not found in Resources folder")
                DispatchQueue.main.async {
                    // GIFが見つからない場合はデフォルト画像を表示
                    imageView.image = NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
                }
                return
            }
            
            guard let imageData = try? Data(contentsOf: bundleURL) else {
                print("Cannot turn GIF named \(name) into data")
                DispatchQueue.main.async {
                    imageView.image = NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
                }
                return
            }
            
            DispatchQueue.main.async {
                coordinator.startGifAnimation(imageView: imageView, gifData: imageData)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var currentGifName: String?
        private var animationTimer: Timer?
        private var currentFrameIndex = 0
        private var gifFrames: [NSImage] = []
        private var frameDurations: [Double] = []
        
        func startGifAnimation(imageView: NSImageView, gifData: Data) {
            // 既存のタイマーを停止
            animationTimer?.invalidate()
            animationTimer = nil
            
            // GIFデータを解析
            guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
                imageView.image = NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
                return
            }
            
            let frameCount = CGImageSourceGetCount(source)
            guard frameCount > 0 else {
                imageView.image = NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
                return
            }
            
            // フレームとデュレーションを取得
            gifFrames.removeAll()
            frameDurations.removeAll()
            
            for i in 0..<frameCount {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                    gifFrames.append(nsImage)
                    
                    let duration = frameDurationAtIndex(i, source: source)
                    frameDurations.append(duration)
                }
            }
            
            if gifFrames.isEmpty {
                imageView.image = NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
                return
            }
            
            // 最初のフレームを表示
            currentFrameIndex = 0
            imageView.image = gifFrames[0]
            
            // アニメーションタイマーを開始
            if gifFrames.count > 1 {
                startAnimationTimer(imageView: imageView)
            }
        }
        
        private func startAnimationTimer(imageView: NSImageView) {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                self.currentFrameIndex = (self.currentFrameIndex + 1) % self.gifFrames.count
                imageView.image = self.gifFrames[self.currentFrameIndex]
            }
        }
        
        private func frameDurationAtIndex(_ index: Int, source: CGImageSource) -> Double {
            var frameDuration = 0.1
            let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
            if let frameProperties = cfFrameProperties as? [String: Any],
               let gifProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                if let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double {
                    frameDuration = delayTime
                } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double {
                    frameDuration = delayTime
                }
            }
            return frameDuration
        }
        
        deinit {
            animationTimer?.invalidate()
        }
    }
} 