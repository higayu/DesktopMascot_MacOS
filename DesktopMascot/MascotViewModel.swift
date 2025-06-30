//
//  MascotViewModel.swift
//  DesktopMascot
//
//  Created by 東山友輔 on 2025/07/01.
//

import SwiftUI
import Combine
import AppKit

class MascotViewModel: ObservableObject {
    @Published var mode: UsamaruMode = .stop
    @Published var mascotImage = "main"
    @Published var position = CGPoint(x: 100, y: 300)
    @Published var direction = 1 // 1=右, -1=左
    @Published var speedX: CGFloat = 3 // 速度を調整
    @Published var centerY: CGFloat = 300
    @Published var waveCounter: Double = 0
    @Published var waveAmplitude: CGFloat = 10
    @Published var animationFrame = 1
    
    private var timer: Timer?
    private var screenBounds: CGRect = NSScreen.main?.visibleFrame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
    
    init() {
        startTimer()
        updateScreenBounds()
        // 初期画像を設定
        setDefaultImage()
    }
    
    deinit {
        stopTimer()
    }
    
    private func setDefaultImage() {
        // デフォルト画像が存在するかチェック
        print("Checking if main image exists...")
        if NSImage(named: "main") == nil {
            print("Main image not found, using system icon")
            // デフォルト画像が存在しない場合は、システムアイコンを使用
            mascotImage = "NSApplicationIcon"
        } else {
            print("Main image found, using main image")
            mascotImage = "main"
        }
    }
    
    private func updateScreenBounds() {
        if let screen = NSScreen.main {
            screenBounds = screen.visibleFrame
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateAnimation()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateAnimation() {
        switch mode {
        case .patoka:
            patokaAction()
        case .stop:
            // ストップモードでは特別なアニメーションなし
            break
        default:
            break
        }
    }
    
    // ResourcesフォルダのGIFファイルの存在確認
    private func gifExistsInResources(_ name: String) -> Bool {
        let exists = Bundle.main.url(forResource: name, withExtension: "gif") != nil
        print("Checking GIF \(name).gif in Resources folder: \(exists ? "Found" : "Not found")")
        return Bundle.main.url(forResource: name, withExtension: "gif") != nil
    }
    
    private func patokaAction() {
        // パトカーの移動ロジック
        position.x += speedX * CGFloat(direction)
        
        // 画面端で反転
        let windowWidth: CGFloat = 200
        if position.x > screenBounds.maxX - windowWidth/2 || position.x < screenBounds.minX + windowWidth/2 {
            direction *= -1
            // 画像を切り替え（ResourcesフォルダのGIFファイルが存在するかチェック）
            if direction == 1 {
                // 右向き
                if gifExistsInResources("patoka_r") {
                    mascotImage = "patoka_r"
                } else {
                    // GIFファイルが存在しない場合は、パトカーモードを維持
                    print("patoka_r.gif not found, keeping current image")
                }
            } else {
                // 左向き
                if gifExistsInResources("patoka_l") {
                    mascotImage = "patoka_l"
                } else {
                    // GIFファイルが存在しない場合は、パトカーモードを維持
                    print("patoka_l.gif not found, keeping current image")
                }
            }
        }
        
        // 浮き沈み
        waveCounter += 0.2
        let waveOffset = sin(waveCounter) * waveAmplitude
        position.y = centerY + waveOffset
    }
    
    func handleTap() {
        switch mode {
        case .stop:
            stopImageChange()
        case .patoka:
            // パトカーモードでのタップ処理
            break
        default:
            break
        }
    }
    
    func stopImageChange() {
        let images = ["main", "main2", "main3"]
        var availableImages: [String] = []
        
        // 存在する画像のみをリストに追加
        for imageName in images {
            if NSImage(named: imageName) != nil {
                availableImages.append(imageName)
            }
        }
        
        // 利用可能な画像がない場合はデフォルトを使用
        if availableImages.isEmpty {
            availableImages = ["NSApplicationIcon"]
        }
        
        let randomIndex = Int.random(in: 0..<availableImages.count)
        mascotImage = availableImages[randomIndex]
        mode = .stop
    }
    
    func patokaChange() {
        print("Changing to patoka mode...")
        mode = .patoka
        // ResourcesフォルダのパトカーGIFファイルが存在するかチェック
        if gifExistsInResources("patoka_r") {
            mascotImage = "patoka_r"
            print("Using patoka_r.gif for patoka mode")
        } else {
            mascotImage = "main" // フォールバック
            print("patoka_r.gif not found, using main image as fallback")
        }
        direction = 1
        centerY = position.y
        updateScreenBounds()
    }
} 