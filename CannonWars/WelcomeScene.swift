//
//  WelcomeScene.swift
//  Cannon Wars
//
//  Created by Aldanis Vigo on 1/1/17.
//  Copyright © 2017 Aldanis Vigo. All rights reserved.
//

import Foundation
import SpriteKit

public class WelcomeScene: SKScene , SKPhysicsContactDelegate{
    let background_music = SKAudioNode(fileNamed: "Duplez.mp3")
    override public func didMove(to view: SKView) {
        //View Loaded
        //Change background color
        self.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        
        //Game Title Image
        let game_title = SKSpriteNode(imageNamed: "game_title.png")
        game_title.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 0.7)
        self.addChild(game_title)
        
        //Start Button
        let play_button = SKSpriteNode(imageNamed: "play_button.png")
        play_button.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 0.4)
        play_button.name = "play"
        self.addChild(play_button)
        
        //Quit Button
        let quit_button = SKSpriteNode(imageNamed: "quit_button.png")
        quit_button.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 0.25)
        quit_button.name = "quit"
        self.addChild(quit_button)
        
        //Copyright Statement
        let copyright_statement = SKSpriteNode(imageNamed: "copyright_statement.png")
        copyright_statement.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 0.025)
        self.addChild(copyright_statement)
        
        //Duplez background music
        background_music.autoplayLooped = true
        background_music.run(SKAction.play())
        addChild(background_music)
    }
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Touch start
        let touch = touches.first!.location(in: self)
        if (childNode(withName: "play")?.contains(touch))!{
            background_music.run(SKAction.stop())
            let transition = SKTransition.reveal(with: SKTransitionDirection.down, duration: 1.0)
            let chocolate_mountain_level = SKScene(fileNamed: "ChocolateMountainLevel.sks")
            chocolate_mountain_level?.size = CGSize(width: 2048, height: 1080)
            chocolate_mountain_level?.scaleMode = .resizeFill
            self.view?.presentScene(chocolate_mountain_level!, transition: transition)
        }
        if (childNode(withName: "quit")?.contains(touch))!{
            exit(0)
        }
    }
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Touch end
    }
    public func didBegin(_ contact: SKPhysicsContact) {
        //Contact Delegate function
    }
    override public func update(_ currentTime: TimeInterval) {
        //Update
    }
}
