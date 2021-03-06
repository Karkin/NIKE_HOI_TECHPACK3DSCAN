//
//  Geometry.hpp
//  StandardCyborgFusion
//
//  Created by Eric Arneback on 2019-03-20.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include <vector>

#include "Vec3.hpp"
#include "Face3.hpp"
#include "Mat3x4.hpp"
#include "VertexSelection.hpp"

namespace StandardCyborg {

struct RayTraceResult {
    float t = INFINITY;
    int index = -1; // index of hit triangle. -1 if no triangle was hit.
    Vec3 hitPoint;
};

class Geometry
{
public:
    
    // A comment noting that at one point the function on the line below constructed from std::vector of Vec3
    Geometry(const std::vector<Vec3>& positions,
             const std::vector<Vec3>& normals = std::vector<Vec3>(),
             const std::vector<Vec3>& colors = std::vector<Vec3>(),
             const std::vector<Face3>& faces = std::vector<Face3>()
    );
    
    Geometry(const std::vector<Vec3>& positions, const std::vector<Face3>& faces);
    
    Geometry();
    
    Geometry(Geometry&&) = delete;
    Geometry& operator=(Geometry&&) = delete;
    Geometry(Geometry const& other) = delete;
    Geometry& operator=(Geometry const& other) = delete;
    
    /* Construct Geometry with points and triangle faces. */
    //Geometry(Vec3* positions, Vec3* normals, Vec3* colors, int numVertices, int* faces, int numFaces);
    
    /* Construct Geometry with only points; a point cloud. */
    //Geometry(Vec3* positions, Vec3* normals, Vec3* colors, int numVertices);
    
    ~Geometry();
    
    /* Makes this Geometry into a deep copy of 'that'*/
    void copy(const Geometry& that);
    
    /* Return the index of the point that is closest to the queryPoint, in terms of the Euclidean distance. */
    int getClosestPoint(const Vec3& queryPoint);
    
    /* Return the indexes of the `n` points that are closest to the queryPoint, in terms of the Euclidean distance. */
    std::vector<int> getClosestPoints(const Vec3& queryPoint, int n);
    
    RayTraceResult rayTrace(Vec3 rayOrigin, Vec3 rayDirection, float rayMin = 0.001f, float rayMax = 1.0e+30f);
    
    void deleteVertices(const VertexSelection& vertexIndices);
    
    void transform(const Mat3x4& mat);
    
    const std::vector<Vec3>& getPositions() const;
    const std::vector<Vec3>& getNormals() const;
    const std::vector<Vec3>& getColors() const;
    const std::vector<Face3>& getFaces() const;
    
    bool hasPositions() const;
    bool hasNormals() const;
    bool hasColors() const;
    bool hasFaces() const;
    
    void normalizeNormals();
    
    int getNumVertices() const;
    int getNumFaces() const;
    
    bool setVertexData(const std::vector<Vec3>& positions,
                       const std::vector<Vec3>& normals = std::vector<Vec3>(),
                       const std::vector<Vec3>& colors = std::vector<Vec3>());
    
    bool setPositions(const std::vector<Vec3>& positions);
    bool setNormals(const std::vector<Vec3>& normals);
    bool setColors(const std::vector<Vec3>& colors);
    bool setFaces(const std::vector<Face3>& faces);
    
    void setColor(const Vec3& color, float alpha);
    void setColor(const Vec3& color, float alpha, const VertexSelection& vertexIndices);
    
    void mutatePositionsWithFunction(const std::function<Vec3(int index, Vec3 position, Vec3 normal, Vec3 color)>& mapFn);
    void mutateNormalsWithFunction(const std::function<Vec3(int index, Vec3 position, Vec3 normal, Vec3 color)>& mapFn);
    void mutateColorsWithFunction(const std::function<Vec3(int index, Vec3 position, Vec3 normal, Vec3 color)>& mapFn);
    
    void mutatePositionsWithFunction(const std::function<Vec3(int index, Vec3 position, Vec3 normal, Vec3 color)>& mapFn, const VertexSelection& vertexIndices);
    void mutateNormalsWithFunction(const std::function<Vec3(int index, Vec3 position, Vec3 normal, Vec3 color)>& mapFn, const VertexSelection& vertexIndices);
    void mutateColorsWithFunction(const std::function<Vec3(int index, Vec3 position, Vec3 normal, Vec3 color)>& mapFn, const VertexSelection& vertexIndices);
    
    Vec3 getFaceCenter(int faceIndex) const;
    
    int getSize();
    
    static std::set<int> getAllocatedIds();
    static int getNumAllocatedIds();
    static void resetAllocatedIds();
    static void resetIdCounter();
    
private:
    
    void updateDataStructures();
    
    struct Impl;
    std::unique_ptr<Impl> pImpl;
    
    bool _isDirty = true;
    
    std::vector<Vec3> _positions;
    std::vector<Vec3> _normals;
    std::vector<Vec3> _colors;
    std::vector<Face3> _faces;
    
    static std::set<int> _allocatedIds;
    
    int _id;
};


} // namespace StandardCyborg
