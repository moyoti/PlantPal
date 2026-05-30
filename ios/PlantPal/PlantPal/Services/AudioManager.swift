import SwiftUI
import AVFoundation
import Foundation

@Observable
class AudioManager {
    static let shared = AudioManager()
    
    var isMusicOn: Bool = UserDefaults.standard.bool(forKey: "plantpal_music_on") != false {
        didSet { UserDefaults.standard.set(isMusicOn, forKey: "plantpal_music_on") }
    }
    var isSfxOn: Bool = UserDefaults.standard.bool(forKey: "plantpal_sfx_on") != false {
        didSet { UserDefaults.standard.set(isSfxOn, forKey: "plantpal_sfx_on") }
    }
    
    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    func startBGM() {
        guard isMusicOn else { return }
        guard let url = Bundle.main.url(forResource: "bgm_garden", withExtension: "mp3") else { return }
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = 0.4
            bgmPlayer?.play()
        } catch {
            print("BGM load failed: \(error)")
        }
    }
    
    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }
    
    func toggleMusic() {
        isMusicOn.toggle()
        if isMusicOn {
            startBGM()
        } else {
            stopBGM()
        }
    }
    
    func playSFX(_ name: String) {
        guard isSfxOn else { return }
        let fileName = "sfx_\(name)"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.6
            player.play()
            sfxPlayers[fileName] = player
        } catch {
            print("SFX \(fileName) load failed: \(error)")
        }
    }
    
    func playInteractionSFX(_ type: InteractionType) {
        switch type {
        case .water: playSFX("water")
        case .light: playSFX("light")
        case .fertilize: playSFX("fertilize")
        case .touch: playSFX("touch")
        case .pet: playSFX("pet")
        case .talk: playSFX("talk")
        case .sing: playSFX("sing")
        case .heal: playSFX("heal")
        case .play: playSFX("play")
        case .shield: playSFX("shield")
        case .dance: playSFX("dance")
        }
    }
    
    func playPurchase() { playSFX("purchase") }
    func playEquip() { playSFX("equip") }
    func playTap() { playSFX("tap") }
}