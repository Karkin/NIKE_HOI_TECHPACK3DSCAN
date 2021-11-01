//
//  LandmarkFileIO_JSON.hpp
//  StandardCyborgIO
//
//  Created by Ricky Reusser on 7/12/19.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include "Landmark.hpp"

#include <ostream>

namespace StandardCyborg {

/** Read landmark from JSON into an existing Landmark instance */
extern bool ReadJSONIntoLandmark(Landmark& destination, const std::string& input, bool isInputFilename);

/** Read landmark and return a new Landmark instance */
extern Landmark ReadLandmarkFromJSON(const std::string& input, bool isInputFilename);

/** Serialize landmark into an ostream */
extern void SerializeLandmarkToJSON(std::ostream& output, const Landmark& landmark);
    
/** Serialize Landmark and write them into a file */
extern bool WriteLandmarkToJSONFile(const Landmark& landmark, std::string filename);

} // namespace StandardCyborg

