//
//  GeometryDebugging.hpp
//  StandardCyborgGeometry
//
//  Created by Ricky Reusser on 3/31/19.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include <ostream>

#include "MeshTopology.hpp"

namespace StandardCyborg {

class Vec2;
class Vec3;
class Vec4;
class Face3;
struct Mat3x4;
struct Mat3x3;
struct Mat4x4;
class VertexSelection;
struct Plane;
class Polyline;
struct BoundingBox3;

std::ostream& operator<<(std::ostream& os, const Vec2& v);
std::ostream& operator<<(std::ostream& os, const Vec3& v);
std::ostream& operator<<(std::ostream& os, const Vec4& v);
std::ostream& operator<<(std::ostream& os, const Face3& v);
std::ostream& operator<<(std::ostream& os, const Mat4x4& v);
std::ostream& operator<<(std::ostream& os, const Mat3x4& v);
std::ostream& operator<<(std::ostream& os, const Mat3x3& v);
std::ostream& operator<<(std::ostream& os, const VertexSelection& selection);
std::ostream& operator<<(std::ostream& os, const Plane& plane);
std::ostream& operator<<(std::ostream& os, const MeshTopology::Edge& edge);
std::ostream& operator<<(std::ostream& os, const MeshTopology::FaceEdges& edge);
std::ostream& operator<<(std::ostream& os, const MeshTopology::MeshTopology& topology);
std::ostream& operator<<(std::ostream& os, const Polyline& polyline);
std::ostream& operator<<(std::ostream& os, const BoundingBox3& polyline);

} // using namespace StandardCyborg
