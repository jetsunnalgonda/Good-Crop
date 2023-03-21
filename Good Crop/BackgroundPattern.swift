//
//  BackgroundPattern.swift
//  Good Crop
//
//  Created by Haluk Isik on 8/19/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import Foundation
import UIKit


class BackgroundPattern
{
    // MARK: - Outlets
    
    var image: UIImage
    var artistName: String
    var artworkName: String
    
    // MARK: - Initialization
    
    init(imageName: String, artistName: String, artworkName: String)
    {
        image = UIImage(named: imageName)!
        self.artistName = artistName
        self.artworkName = artworkName
    }
    
    // MARK: - Class methods
    
    class func getDefaultPatterns() -> [BackgroundPattern]
    {
        var backgroundPatterns = [BackgroundPattern]()
        var backgroundPatternsAndArtists = [String:[String:String]]()
        
        backgroundPatternsAndArtists = [
            "Shaun Fox": ["bicycles":"Bicycles"],
            "Brijan Powel @brijanp": ["brijan":"Brijan"],
            "Henry & Henry @henryhenry": ["retro-furnish":"Retro Furnish"],
            "Natalia de Frutos @nataliadfrutos": ["kiwis":"Kiwis","naranjas":"Naranjas"],
            "Henry Daubrez @upskydown": ["wild-sea":"Wild Sea", "the-illusionist":"The Illusionist"],
            "Anatoliy Gromov": ["hodgepodge":"Hodgepodge"],
            "Raul Varela @shonencmyk": ["canvas-orange":"Canvas Orange"],
            "Claudio Gugliery @claudiogugliery": ["nyc-candy":"NYC Candy", "chalkboard":"Chalkboard", "leather-nunchuck":"Leather Nunchuck", "ripples":"Ripples", "kale-salad":"Kale Salad"],
            "Kristoffer Brady @egosmoke": ["magnus-2052":"Magnus 2052", "magnus-2050":"Magnus 2050"],
            "Julien Bailly @julien_bailly": ["fiesta":"Fiesta", "maze":"Maze"],
            "Alexey Tretina @squilacci": ["plaid":"Plaid"],
            "Fabricio Marquez @fabric_8": ["science":"Science"],
        ]
        
        for (artistName, dictionary) in backgroundPatternsAndArtists {
            for (imageName, artworkName) in dictionary {
                backgroundPatterns.append(BackgroundPattern(imageName: imageName, artistName: artistName, artworkName: artworkName))
            }
        }
        
//        let sortedByKeyAsc = sorted(backgroundPatterns) { $0.artworkName < $1.artworkName }

        
        return backgroundPatterns.sort { $0.artworkName < $1.artworkName }
    }
}