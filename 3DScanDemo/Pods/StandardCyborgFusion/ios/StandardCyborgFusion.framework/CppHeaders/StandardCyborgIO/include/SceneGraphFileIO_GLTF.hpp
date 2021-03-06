//
//  SceneGraphFileIO_GLTF.hpp
//  StandardCyborgIO
//
//  Created by eric on 2019-06-25.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include "SceneGraph.hpp"

namespace StandardCyborg {

/** Read from a string formatted as gltf-file. */
std::shared_ptr<Node> ReadSceneGraphFromGltf(const std::string& gltfSource);

/** Write a Scene graph to a path. */
bool WriteSceneGraphToGltf(Node* sceneGraph, const std::string& path);

} // namespace StandardCyborg
