//
//  PolylineFileIO_JSON.hpp
//  StandardCyborgIO
//
//  Created by Ricky Reusser on 2019-07-10.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include "Polyline.hpp"

#include <ostream>

namespace StandardCyborg {

/** Read polyline from JSON into an existing Polyline instance */
extern bool ReadJSONIntoPolyline(Polyline& destination, const std::string& input, bool isInputFilename);

/** Read polyline and return a new Polyline instance */
extern Polyline ReadPolylineFromJSON(const std::string& input, bool isInputFilename);

/** Serialize polyline into an ostream */
extern void SerializePolylineToJSON(std::ostream& output, const Polyline& polyline);
    
/** Serialize Polyline and write them into a file */
extern bool WritePolylineToJSONFile(const Polyline& polyline, std::string filename);

} // namespace StandardCyborg
