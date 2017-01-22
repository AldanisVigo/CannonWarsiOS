//
//  ChocolateMountainLevel.swift
//  Cannon Wars
//
//  Created by Aldanis Vigo on 1/1/17.
//  Copyright © 2017 Aldanis Vigo. All rights reserved.
//
import Foundation
import SpriteKit
import AudioToolbox
public class ChocolateMountainLevel: SKScene, SKPhysicsContactDelegate{
    //Cannon Variables
    var cannon_barrel:SKNode?
    var cannon_ball_speed_constant:CGFloat?
    //Camera
    public var cam:SKCameraNode?
    //Sound
    let background_music = SKAudioNode(fileNamed: "chocolate_mountain.mp3")
    let hit_sound = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
    let explosion_sound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
    //Contact bitmask categories
    let CannonBallCategory:UInt32 = 0x01 << 0
    let FloorCategory:UInt32 = 0x01 << 1
    let BuildingCategory:UInt32 = 0x01 << 2
    //Slider
    var slider_knob_min_y:CGFloat = 0.0
    var slider_knob_max_y:CGFloat = 0.0
    //Vibrate action
    let vibrate_action = SKAction.run() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    //Sun position offsets
    var sunCameraXOffset:CGFloat?
    var sunCameraYOffset:CGFloat?
    
    
    //zPositions
    enum zPositions: CGFloat{
        case SUN = -8.0
        case CLOUD = -7.0
        case MOUNTAIN = -6.0
        case FLOOR = -5.0
        case BUSH = -5.1
        case TREETRUNK = -5.2
        case PALMFROND = -4.0
    }
    
    override public func didMove(to view: SKView) {
        //Add gesture recognizers
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.respondToTapGesture))
        self.view?.addGestureRecognizer(tapGesture)
        cannon_barrel = childNode(withName: "main_cannon_barrel")
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.7)
        
        //Setup camera
        cam = childNode(withName: "cam") as! SKCameraNode?
        self.camera = cam 
        cam?.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        cam?.physicsBody = SKPhysicsBody(rectangleOf: (cam?.frame.size)!)
        //chocolate_mountain background music
        background_music.autoplayLooped = true
        background_music.run(SKAction.play())
        addChild(background_music)
        
        //Setup categoryBitMasks
        self.physicsWorld.contactDelegate = self
        childNode(withName: "floor")?.physicsBody?.categoryBitMask = FloorCategory
        enumerateChildNodes(withName: "column") {
            node, stop in
            node.physicsBody?.categoryBitMask = self.BuildingCategory
        }
        enumerateChildNodes(withName: "building_floor") {
            node, stop in
            node.physicsBody?.categoryBitMask = self.BuildingCategory
        }
        
        //Slider knob min and max values
        let slider_knob = self.childNode(withName: "slider_knob")
        let slider_knob_inner_bg = self.childNode(withName: "slider_inner_background")
        slider_knob_min_y = (slider_knob?.position.y)!
        slider_knob_max_y = (slider_knob_inner_bg?.position.y)! + (slider_knob_inner_bg?.frame.height)! / 2 - (slider_knob?.frame.height)! / 2 - 5.0
        
        //Palm Trees grow/shrink effect  / Z-Positioning
        let growAmount:CGFloat = 2.0
        let rotateAmount:CGFloat = 0.02
        let grow = SKAction.resize(byWidth: growAmount, height: 0.0, duration: 0.3)
        let shrink = SKAction.resize(byWidth: -growAmount, height: 0.0, duration: 0.3)
        let rotateLeft = SKAction.rotate(byAngle: -rotateAmount, duration: 0.3)
        let rotateRight = SKAction.rotate(byAngle: rotateAmount, duration: 0.3)
        let wait = SKAction.wait(forDuration: 1.0)
        let growShrinkSequence = SKAction.sequence([grow,rotateLeft,wait,rotateRight,rotateRight,wait,rotateLeft,shrink])
        let repeatGrowShrinkSequenceForever = SKAction.repeatForever(growShrinkSequence)
        //Sun
        cam!.childNode(withName: "sun")!.zPosition = -8.0 //Rear of the scene
        //Clouds
        enumerateChildNodes(withName: "cloud"){
            node, stop in
            node.zPosition = zPositions.CLOUD.rawValue //In front of the sun but behind the chocolate mountains
        }
        //Chocolate Mountains
        enumerateChildNodes(withName: "chocolate_mountain"){
            node, stop in
            node.zPosition = zPositions.MOUNTAIN.rawValue //In front of the clouds but behind the trees and floor
        }
        //Floor & Bushes & Tree trunks
        childNode(withName: "floor")!.zPosition = -5.0
        enumerateChildNodes(withName: "trunk"){
            node, stop in
            node.zPosition = zPositions.TREETRUNK.rawValue
        }
        //Bushes
        enumerateChildNodes(withName: "bush"){
            node,stop in
            node.run(repeatGrowShrinkSequenceForever)
            node.zPosition = zPositions.BUSH.rawValue
        }
        //Palm Tree Leaf Inner
        enumerateChildNodes(withName: "frond"){
            node,stop in
            node.run(repeatGrowShrinkSequenceForever)
            node.zPosition = zPositions.PALMFROND.rawValue
        }
        self.lastCamPos = cam?.position
    }
    var onSlider:Bool = false
    func respondToTapGesture(sender: UITapGestureRecognizer){
        //let tapLocation = sender.location(in: self.view)
        if cam?.position == CGPoint(x: self.frame.width / 2, y: self.frame.height / 2) && !onSlider{
            //Add new cannon ball
            let my_cannon_ball = SKSpriteNode(imageNamed: "cannon_ball.png")
            let tipOfCannon = CGPoint(x: (cannon_barrel?.position.x)! + 2, y: (cannon_barrel?.position.y)! + 8)
            my_cannon_ball.position = tipOfCannon
            my_cannon_ball.physicsBody = SKPhysicsBody(texture: my_cannon_ball.texture! , size: my_cannon_ball.size)
            my_cannon_ball.zPosition = 3.0
            my_cannon_ball.name = "my_cannon_ball"
            my_cannon_ball.physicsBody?.categoryBitMask = CannonBallCategory
            my_cannon_ball.physicsBody?.contactTestBitMask = FloorCategory | BuildingCategory
            addChild(my_cannon_ball)
            let angleInRadian = Float((cannon_barrel?.zRotation)!)
            let xComponent = CGFloat(cosf(angleInRadian)) * cannon_ball_speed_constant!
            let yComponent = CGFloat(sinf(angleInRadian)) *  cannon_ball_speed_constant!
            let impulseVector = CGVector(dx: xComponent, dy: yComponent)
            my_cannon_ball.physicsBody!.applyImpulse(impulseVector)
            run(explosion_sound)
        }
    }
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Touches Begin
    }
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentLocation = touches.first?.location(in: self)
        let percent = (currentLocation?.y)! / self.frame.size.height
        let angle = percent * 180 - 180
        let slider_background = childNode(withName: "slider_background")
        if !(slider_background?.contains(currentLocation!))!{
            onSlider = false
            cannon_barrel?.zRotation = CGFloat(angle) * CGFloat(M_PI) / 180.0 + CGFloat(M_PI) * 0.5
        }else{
            onSlider = true
            let slider_knob = childNode(withName: "slider_knob")
            slider_knob?.position.y = (touches.first?.location(in: self).y)!
        }
    }
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Touched Ended
    }
    var contact_happened = false
    public func didBegin(_ contact: SKPhysicsContact) {
        //Contact Delegate Function
        let contactLocation = contact.contactPoint
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == (CannonBallCategory | FloorCategory){
            //Emit explosion and smoke particles
            //Explosion Particle
            let explosion_particle = SKEmitterNode(fileNamed: "cannon_ball_hit.sks")
            explosion_particle?.position = contactLocation
            contact_happened = true
            explosion_particle?.targetNode = self
            explosion_particle?.zPosition = 7
            addChild(explosion_particle!)
            //Smoke Particle
            let smokeBit = SKEmitterNode(fileNamed: "cannon_ball_smoke_trail.sks")
            smokeBit?.position = contactLocation
            smokeBit?.targetNode = self
            smokeBit?.zPosition = 7
            addChild(smokeBit!)
            contact.bodyB.node?.removeFromParent()
            run(hit_sound)
            run(vibrate_action)
        }
        //Reset the camera to initial position
        let camera_return = SKAction.move(to: CGPoint(x: frame.width / 2, y: frame.height / 2), duration: 2.0)
        let wait_a_sec = SKAction.wait(forDuration: 2.0)
        let camera_reset = SKAction.sequence([wait_a_sec,camera_return])
        if (cam?.position.x)! > frame.width{
            self.cam!.run(camera_reset)
        }
    }
    public func didEnd(_ contact: SKPhysicsContact) {
//        let separation = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//        let hitLocation = contact.contactPoint
        //Reset the camera to initial position
        let camera_return = SKAction.move(to: CGPoint(x: frame.width / 2, y: frame.height / 2), duration: 2.0)
        let wait_a_sec = SKAction.wait(forDuration: 2.0)
        let camera_reset = SKAction.sequence([wait_a_sec,camera_return])
        if (cam?.position.x)! > frame.width{
            self.cam!.run(camera_reset)
        }
    }
    var currentFrame = 0
    var secondsElapsed = 0
    var currentWait = 1
    func generate_clouds(){
        //Generate random clouds
        currentFrame += 1
        if(currentFrame == 60){
            secondsElapsed += 1
            currentFrame = 0
        }
        if(secondsElapsed == currentWait){
            //Do create new cloud
            let newCloud = SKSpriteNode(imageNamed: "cloud.png")
            let upperOffset:CGFloat = 8.0
            let upperBound = frame.height - newCloud.frame.height / 2 + upperOffset
            let lowerBound = frame.height * 0.5
            let startingXPosition = self.position.x - self.frame.width / 2 - newCloud.frame.width / 2
            let randomYPosition = UInt32(lowerBound) + arc4random_uniform(UInt32(upperBound) - UInt32(lowerBound) + 1)
            newCloud.position = CGPoint(x: startingXPosition, y: CGFloat(randomYPosition))
            newCloud.zPosition = zPositions.CLOUD.rawValue
            newCloud.name = "cloud"
            addChild(newCloud)
            //Calculate a new currentWait
            let newCurrentWait = arc4random_uniform(3) + 1
            currentWait = Int(newCurrentWait)
            //Reset secondsElapsed
            secondsElapsed = 0
        }
        //Move all clouds to the right by a set windspeed
        let windSpeed:CGFloat = 1.2
        enumerateChildNodes(withName: "cloud") {
            node, stop in
            node.position.x += windSpeed
            //Remove clouds that are off screen
            if node.position.x > (self.childNode(withName:"floor")!.frame.width + self.frame.width + node.frame.width / 2){
                node.removeFromParent()
            }
        }
    }
    func limit_cannon_angles(){
        let cannon_lowest_rotation_angle:CGFloat = -0.75
        let cannon_highest_rotation_angle:CGFloat = 0.90
        if((cannon_barrel?.zRotation)! < cannon_lowest_rotation_angle){
            cannon_barrel?.zRotation = cannon_lowest_rotation_angle
        }
        if((cannon_barrel?.zRotation)! > cannon_highest_rotation_angle){
            cannon_barrel?.zRotation = cannon_highest_rotation_angle
        }
    }
    func control_scene_camera(){
        if let cannon_ball = childNode(withName: "my_cannon_ball"){
            //Reset the camera to initial position
            let camera_return = SKAction.move(to: CGPoint(x: frame.width / 2, y: frame.height / 2), duration: 2.0)
            let wait_a_sec = SKAction.wait(forDuration: 2.0)
            let camera_reset = SKAction.sequence([wait_a_sec,camera_return])
            if(cannon_ball.position.y < (childNode(withName: "floor")?.position.y)!){
                cannon_ball.removeFromParent()
                self.cam?.run(camera_reset)
            }
            if(cannon_ball.position.x > (childNode(withName: "floor")?.position.x)! + (childNode(withName: "floor")?.frame.width)! / 2){
                cannon_ball.removeFromParent()
                self.cam?.run(camera_reset)
            }
            if contact_happened != true{
                if cannon_ball.position.x > frame.width + cannon_ball.frame.width / 2 || cannon_ball.position.y > frame.height + cannon_ball.frame.height / 2{
                    let move_to_cannon_ball = SKAction.move(to: cannon_ball.position, duration: 0.1)
                    let wait_a_sec = SKAction.wait(forDuration: 2.0)
                    let goAndReturnSequence = SKAction.sequence([move_to_cannon_ball,wait_a_sec,camera_return])
                    self.cam?.run(goAndReturnSequence)
                    
                }
            }
        }else{
            contact_happened = false
        }
    }
    func calculate_slider_position(){
        let slider_knob = childNode(withName: "slider_knob")
        if((slider_knob?.position.y)! < slider_knob_min_y){
            slider_knob?.position.y = slider_knob_min_y
        }
        if((slider_knob?.position.y)! > slider_knob_max_y){
            slider_knob?.position.y = slider_knob_max_y
        }
        //Calculate and print out slider value based on a max
        let sliderOutputMin:CGFloat = 0.8
        let sliderOutputMax:CGFloat = 5.0
        let sliderValue = map(x: (slider_knob?.position.y)!,a: slider_knob_min_y, b: slider_knob_max_y,c: sliderOutputMin, d: sliderOutputMax)
        cannon_ball_speed_constant = sliderValue
    }
    func map(x: CGFloat, a: CGFloat, b: CGFloat,c: CGFloat, d: CGFloat) -> CGFloat{
        /*
            //function for mapping a value x which is between a and b to a value y between c and d
            x -> [a,b] ===> y -> [c,d]
                        d - c
            y = (x - a) ----- + c
                        b - a
        */
        return CGFloat((x - a) * ((d - c) / (b - a)) + c)
    }
    var framesCounted = 0
    func handle_cannon_ball_smoke_trail(){
        let targetFrameFrequency = 1
        framesCounted += 1
        if framesCounted > targetFrameFrequency{
            //Reset when we reach the desired frame
            framesCounted = 0
            if let cannon_ball = childNode(withName: "my_cannon_ball"){
                let cannon_ball_pos = cannon_ball.position
                let smokeBit = SKEmitterNode(fileNamed: "cannon_ball_smoke_trail.sks")
                smokeBit?.position = cannon_ball_pos
                smokeBit?.targetNode = self
                smokeBit?.zPosition = 7
                addChild(smokeBit!)
            }
        }
    }
    var runAwayCamSecCounter = 0
    var runAwayCamCurFrame = 0
    var lastCamPos:CGPoint?
    let returnCamAfterThisManySecs = 15
    func check_for_runAwayCamera(){
        runAwayCamCurFrame += 1
        if runAwayCamCurFrame == 60{
            runAwayCamSecCounter += 1
        }
        if runAwayCamSecCounter == returnCamAfterThisManySecs{
            if cam?.position != CGPoint(x: frame.width / 2, y: frame.height / 2){
                if(cam?.position == lastCamPos){
                    //If 15 seconds have gone by and the camera is stuck at a position other than the starting position
                    //Reset the camera to initial position
                    let camera_return = SKAction.move(to: CGPoint(x: frame.width / 2, y: frame.height / 2), duration: 2.0)
                    let wait_a_sec = SKAction.wait(forDuration: 2.0)
                    let camera_reset = SKAction.sequence([wait_a_sec,camera_return])
                    self.cam?.run(camera_reset)
                }
            }else{
                lastCamPos = cam?.position
            }
        }
        
    }
    override public func update(_ currentTime: TimeInterval) {
        //Frame update, runs before every frame
        generate_clouds()
        limit_cannon_angles()
        calculate_slider_position()
        control_scene_camera()
        handle_cannon_ball_smoke_trail()
        check_for_runAwayCamera()
    }
}
