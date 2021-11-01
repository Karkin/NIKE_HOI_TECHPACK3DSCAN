//
//  GeometryFileIO_PLY.hpp
//  StandardCyborgGeometry
//
//  Created by Aaron Thompson on 4/2/19.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include <memory>
#include <string>
#include <vector>
#include "Geometry.hpp"

namespace StandardCyborg {

/** Assumes file has sRGB color space, and reads into linear color space */
extern std::unique_ptr<Geometry> ReadGeometryFromPLYFile(std::string filename);

/** Assumes file has sRGB color space, and reads into linear color space */
/** if isInputFilename==true, then `input` is the filename of a ply-file, otherwise its a string representing
    the contents of a ply-file.  */
extern std::unique_ptr<Geometry> RobustReadGeometryFromPLY(const std::string& input);

/** Read geometry from a PLY file into an existing Geometry instance */
extern void RobustReadPLYIntoGeometry(Geometry* destination, const std::string& filename);

/** Read geometry from a stream of PLY data into an existing Geometry instance */
extern void RobustReadPLYIntoGeometry(Geometry* destination, std::istream& inStream);

/** Assumes vertices are in linear color space, and writes to file in sRGB color space */
extern void SerializeGeometryToPLY(std::ostream& output, const Geometry& geometry);

/** Assumes vertices are in linear color space, and writes to file in sRGB color space */
extern bool WriteGeometryToPLYFile(const Geometry& geometry,
                                   std::string filename);

} // namespace StandardCyborg
