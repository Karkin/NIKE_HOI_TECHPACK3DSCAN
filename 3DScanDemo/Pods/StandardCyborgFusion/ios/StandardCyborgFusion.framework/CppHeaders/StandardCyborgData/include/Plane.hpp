//
//  Plane.hpp
//  StandardCyborgGeometry
//
//  Created by Ricky Reusser on 4/3/19.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include "Vec3.hpp"

namespace StandardCyborg {

// A plane *defined* by
//
//   dot(x - position, normal) == 0
//
// This definition is fairly redundant since only three numbers are required
// to represent a plane, but what we lose in redundancy we gain in simplicity.
struct Plane {
    Vec3 position;
    Vec3 normal;
};

} // namespace StandardCyborg
