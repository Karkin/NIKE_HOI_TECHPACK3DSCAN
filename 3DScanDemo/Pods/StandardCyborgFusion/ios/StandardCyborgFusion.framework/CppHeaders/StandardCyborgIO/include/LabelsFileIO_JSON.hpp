//
//  LabelsFileIO.hpp
//  StandardCyborgIO
//
//  Created by eric on 2019-06-06.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include "Labels.hpp"

#include <ostream>

namespace StandardCyborg {

/** Read labels from JSON into an existing Labels instance */
extern bool ReadJSONIntoLabels(Labels& destination, const std::string& input, bool isInputFilename);

/** Read labels and return a new Labels instance */
extern Labels ReadLabelsFromJSON(const std::string& input, bool isInputFilename);

/** Serialize labels into an ostream */
extern void SerializeLabelsToJSON(std::ostream& output, const Labels& labels);
    
/** Serialize Labels and write them into a file */
extern bool WriteLabelsToJSONFile(const Labels& labels, std::string filename);

} // namespace StandardCyborg
