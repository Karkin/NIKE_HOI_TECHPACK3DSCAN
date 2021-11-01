//
//  SceneGraph.hpp
//  StandardCyborgSceneGraph
//
//  Created by eric on 2019-06-07.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#pragma once

#include "Geometry.hpp"
#include "Labels.hpp"
#include "Landmark.hpp"
#include "Polyline.hpp"
#include <vector>
#include <string>
#include <stack>
#include "crossguid/guid.hpp"

namespace StandardCyborg {

enum class SGNodeType {
    Generic,
    Geometry,
    Labels,
    ValueField,
    Landmark,
    Polyline
};

struct GeometryNode;
struct LabelsNode;
struct ValueFieldNode;
struct LandmarkNode;
struct PolylineNode;

struct Material {
    Vec3 emissive;
};

typedef xg::Guid Uuid;

struct Node {

private:
    std::vector<std::shared_ptr<Node>> children;
    Mat3x4 transform;
    std::string name;
    Material material;
    
    Uuid resourceId;
    
    int nodeRevision = 0;
    int treeRevision = 0;

    friend class UndoRedoManager;

protected:
    std::string dataURI;
    bool dataResolved = true;
    
    Uuid id;

public:
    /** Construct an empty node */
    Node();
    
    virtual ~Node();
    
    /*
     Get list of the resource ids, of all allocated nodes so far.
     Useful for tracking whether we have memory leaks.
     */
    static std::vector<Uuid> getAllocatedResources();
    static int getNumAllocatedResources();
    
    /*
     clear the list of allocated resource ids. mainly useful for unit testing.
     */
    static void resetAllocatedResources();
    
    static std::shared_ptr<Node> findParent(std::shared_ptr<Node> rootNode, std::shared_ptr<Node> targetNode);

    /** Remove and deallocate a node, and all of its children. */
    static bool remove(std::shared_ptr<Node> rootNode, std::shared_ptr<Node> targetNode);
    
    // copy this node contents, to the target.
    void copyToTarget(Node* target) {
        target->transform = this->transform;
        target->name = this->name;
        target->material = this->material;
        target->id = this->id;
        target->nodeRevision = this->nodeRevision;
        target->treeRevision = this->treeRevision;
        target->dataURI = this->dataURI;
        target->dataResolved = this->dataResolved;
    }
    
    /* Copies only this node(and not any of its children), without assigning a new id to the copy. */
    virtual Node* copy() {
        Node* node = new Node();
        
        copyToTarget(node);
        
        return node;
    }
    
    /* Copies only this node(and not any of its children), assigning a new id to the copy. */
    virtual Node* deepCopy();

    /* Deep copy this node and its children, assigning new ids to all copied nodes. */
    std::shared_ptr<Node> deepCopyRecursive();
    
    /** Remove this node from its current parent, and make it the child of some other node.. */
    //bool reparent(Node* newParent);
    
    /** Set the data URI for the serialized content of the current node */
    Node* setDataURI(std::shared_ptr<Node> rootNode, const std::string& str);
    
    /** Set the transform of this node. Does not preserve undo/redo history. */
    void setTransform(const Mat3x4& transform);
    
    /** Set the transform of this node */
    Node* setTransform(std::shared_ptr<Node> rootNode, const Mat3x4& transform);
    
    /** Mark this node as having its data resolved */
    Node* markDataResolved(std::shared_ptr<Node> rootNode);
    
    /** Mark this node as not having its data resolved */
    Node* markDataUnresolved(std::shared_ptr<Node> rootNode);
    
    /** Set the name of this node. */
    Node* setName(std::shared_ptr<Node> rootNode, const std::string& name);
    
    /** Return the current tree revision counter value */
    int getTreeRevision() const;
    
    /** Return the current node revision counter value */
    int getNodeRevision() const;
    
    /** Increment the revision counter and propagate up to the root node */
    void touch(std::shared_ptr<Node> rootNode);
    
    /** Recursively traverse, and check for equality between two nodes, and all of its children.
     We can turn off check equality of the revision counters, since you dont always want to
     check them for equality in unit testing.
     */
    bool equals(Node* that, bool checkRevisionCounters = false);
    
    /** Gets the number of children of this node */
    int numChildren() const;
    
    /** Get an integer identifier, unique only per-execution */
    Uuid getId() const;
    
    /** If a node is re-allocated because of mutateNode, it still has the same
      value of getId(). However, however, the resourceId of this re-allocated node
      is new, and different from the old node. */
    Uuid getResourceId() const;
    
    /** Get the data URI of the serialized content of the current node */
    std::string getDataURI() const;

    /** Gets child #i */
    Node* getChild(int i) const;
    std::shared_ptr<Node> getChildSharedPtr(int i) const;

    /** Returns the index of the specified child node of this parent node, or -1 if not found */
    int indexOfChild(std::shared_ptr<Node> childNode);
    
    /** Adds a child node under this node. Does not preserve undo/redo history. */
    bool addChild(std::shared_ptr<Node> child);
    
    /** Removes the specified child node of this node. Does not preserve undo/redo history. */
    bool removeChild(std::shared_ptr<Node> childNode);
    
    /** Removes all child nodes of this node. Does not preserve undo/redo history. */
    void removeAllChildren();
    
    /** Adds a child node under the specified parent node */
    static bool pushChild(std::shared_ptr<Node> rootNode,
                          std::shared_ptr<Node> parent,
                          std::shared_ptr<Node> child);
    
    /** Push a list of children under the specified parent node */
    static bool pushChildren(std::shared_ptr<Node> rootNode,
                             std::shared_ptr<Node> parent,
                             const std::vector<std::shared_ptr<Node>>& children);
    
    std::shared_ptr<Node> firstChildNamed(std::string name);
    
    /** Gets the transform of this node */
    Mat3x4 getTransform() const;

    /** Whether data reference has been resolved and parsed */
    bool dataIsResolved() const;
    
    /** Gets the name of this node. */
    std::string getName() const;

    /** gets the material of this node */
    Material getMaterial() const;
    
    /** gets the material of this node */
    Material& getMaterial();
    
    /** Checks whether this is a GeometryNode */
    bool isGeometryNode() const;
    /** Cast this node to GeometryNode, and returns */
    GeometryNode* asGeometryNode();

    /** Checks whether this is a LabelsNode */
    bool isLabelsNode() const;
    /** Cast this node to LabelsNode, and returns */
    LabelsNode* asLabelsNode();
    
    /** Checks whether this is a ValueFieldNode */
    bool isValueFieldNode() const;
    /** Cast this node to ValueFieldNode, and returns */
    ValueFieldNode* asValueFieldNode();

    /** Checks whether this is a PolylineNode */
    bool isPolylineNode() const;
    /** Cast this node to PolylineNode, and returns */
    PolylineNode* asPolylineNode();

    /** Checks whether this is a LandmarkNode */
    bool isLandmarkNode() const;
    /** Cast this node to LandmarkNode, and returns */
    LandmarkNode* asLandmarkNode();
    
    /** Gets the NodeType of this node */
    virtual SGNodeType getType() const;

    /** Gets the memory size of the contents of this Node. NB: this doesnt include the children of this node. */
    virtual int getSize() const;

    static std::shared_ptr<Node> mutateNode(std::shared_ptr<Node> targetNode,
                                            std::shared_ptr<Node> rootNode,
                                            const std::function<void(std::shared_ptr<Node>, std::shared_ptr<Node>)>& mutateFn);
    
    static std::shared_ptr<Node> findNodeWithId(std::shared_ptr<Node> rootNode, Uuid id);

    static int calculateHistorySize(const std::vector<std::shared_ptr<Node>>& history);
};
    
struct GeometryNode : public Node {
private:
    std::shared_ptr<Geometry> geometry;
    
public:
    /** Constructs an empty geometry node */
    GeometryNode();
    
    virtual ~GeometryNode();
    
    /** Get a pointer to the instance's geometry */
    Geometry* getGeometry();
    
    void setGeometry(std::shared_ptr<Geometry> otherGeometry);
    
    virtual GeometryNode* copy() {
        GeometryNode* geoNode = new GeometryNode();
        
        copyToTarget(geoNode);
        
        geoNode->geometry = std::shared_ptr<Geometry>(this->geometry);
        
        return geoNode;
    }
    
    virtual GeometryNode* deepCopy();
    
    /** Gets the node type of this node. */
    virtual SGNodeType getType() const;
    
    virtual int getSize() const;
};

struct LabelsNode : public Node {
private:
    std::shared_ptr<Labels> labels;

public:
    /** Construct an empty labels node */
    LabelsNode();
    
    /** Get a pointer to the instance's labels */
    Labels* getLabels();
    
    virtual LabelsNode* copy() {
        LabelsNode* labelsNode = new LabelsNode();
        
        copyToTarget(labelsNode);
        
        labelsNode->labels = std::shared_ptr<Labels>(this->labels);
        
        return labelsNode;
    }
    
    virtual LabelsNode* deepCopy();

    /** Gets the node type of this node. */
    virtual SGNodeType getType() const;
    
    virtual int getSize() const;
};

struct ValueFieldNode : public Node {
private:
    
    std::shared_ptr<std::vector<float>> values;
    
public:
    /** Construct an empty value field node */
    ValueFieldNode();
    
    /** Gets the values of the value-field represented by this node. */
    std::vector<float>* getValues();
    
    void setValues(const std::vector<float>& values_);
    
    virtual ValueFieldNode* copy() {
        ValueFieldNode* node = new ValueFieldNode();
        
        copyToTarget(node);
        
        node->values = std::shared_ptr<std::vector<float>>(this->values);
        
        return node;
    }

    virtual ValueFieldNode* deepCopy();

    /** Gets the type of this node. */
    virtual SGNodeType getType() const;
    
    virtual int getSize() const;
};

struct LandmarkNode : public Node {
private:
    /** Construct an empty landmark node */
    std::shared_ptr<Landmark> landmark;
    
public:
    /** Construct an empty landmark node */
    LandmarkNode();

    /** Gets the landmarks of this node. */
    Landmark* getLandmark();
    
    virtual LandmarkNode* copy() {
        LandmarkNode* node = new LandmarkNode();
        
        copyToTarget(node);
        
        node->landmark = std::shared_ptr<Landmark>(this->landmark);
        
        return node;
    }

    virtual LandmarkNode* deepCopy();

    /** Gets the type of this node. */
    virtual SGNodeType getType() const;
    
    virtual int getSize() const;
};

struct PolylineNode : public Node {
private:
    
    std::shared_ptr<Polyline> polyline;
    
public:
    /** Construct an empty polyline node */
    PolylineNode();

    /** Gets the Polyline of this node */
    Polyline* getPolyline();
    
    /** Sets the Polyline of this node */
    void setPolyline(Polyline& newPolyline);
    
    /** Gets the type of this node. */
    virtual SGNodeType getType() const;
    
    virtual PolylineNode* copy() {
        PolylineNode* node = new PolylineNode();
        
        copyToTarget(node);
        
        node->polyline = std::shared_ptr<Polyline>(this->polyline);
        
        return node;
    }
    
    virtual PolylineNode* deepCopy();

    virtual int getSize() const;
};


class NodeIterator {
private:
    
    std::shared_ptr<Node> _parent;
    int _childIndex;
    
public:
    
    NodeIterator(std::shared_ptr<Node> parent, int childIndex = 0) :
        _parent(parent), _childIndex(childIndex) {}
    
    std::shared_ptr<Node> operator*() {
        return _parent->getChildSharedPtr(_childIndex);
    }
    
    NodeIterator operator++() {
        NodeIterator iterator = *this;
        ++_childIndex;
        return iterator;
    }
    
    bool operator==(const NodeIterator& rhs) {
        return _childIndex == rhs._childIndex;
    }
    
    bool operator!=(const NodeIterator& rhs) {
        return _childIndex != rhs._childIndex;
    }
    
};

NodeIterator begin(std::shared_ptr<Node> parent);
NodeIterator end(std::shared_ptr<Node> parent);

}
