#include <iostream>
#include "ctree.h"
#include <tuple>
using namespace std;

u128  range_middle(Range const &range) {
    return range.first + ((range.second - range.first) / 2);
};

bool range_contains(const Range &range, const u128 value) {
    return (range.first <= value) && (value <= range.second);
};

//Node * left;
//Node * right;
//u128 key;
//unsigned char height;
//vector<Range> ranges;

Node* create_node(const Range &range){

    std::vector<Range> ranges(1);
    ranges[0] = range;
    Node* n = new Node{NULL, NULL, range_middle(range), 1, ranges};
    return n ;
}

Tree::Tree() {
    root = NULL;
}
Node *Tree::insert(Node* node, Range const &range){
    if (node == NULL) {
        node = create_node(range);
        return node;
    }
    if (range_contains(range, node->key)) {
        node->ranges.push_back(range);
        return node;
    }

    if (range.second < node->key){
        node->left = insert(node->left, range);
    }
    else {
        node->right = insert(node->right, range);
    }

    node->height = 1 + max(get_height(node->left), get_height(node->right));
    signed char balance = get_balance(node);
    u128 key = range_middle(range);

    if ((balance > 1) && (key < node->left->key)){
        return rotate_right(node);
    }

    if ((balance < -1) && (key > node->right->key)){
        return rotate_left(node);
    }

    if ((balance > 1) && (key > node->left->key)){
        node->left = rotate_left(node->left);
        return rotate_right(node);
    }
    if ((balance < -1) && (key < node->right->key)){
        node->right = rotate_right(node->right);
        return rotate_left(node);
    }

    return node;
}

void Tree::insert(const Range& range){
    root = this->insert(root, range);
}

signed char Tree::get_balance(Node const *node)
{
    if (node == NULL) {
        return 0;
    }

    return get_height(node->left) - get_height(node->right);
}

signed char Tree::get_height(Node const *node)
{
    if (node == NULL) {
        return 0;
    }
    return node->height;
}

Node *Tree::rotate_left(Node * node)
{
    Node* y = node->right;
    Node* T2 = y->left;
    y->left = node;
    node->right = T2;
    node->height = 1 + max(get_height(node->left), get_height(node->right));
    y->height = 1 + max(get_height(y->left), get_height(y->right));
    return y;

}

Node *Tree::rotate_right(Node * node)
{
    Node* y = node->left;
    Node* T3 = y->right;
    y->right = node;
    node->left = T3;
    node->height = 1 + max(get_height(node->left), get_height(node->right));
    y->height = 1 + max(get_height(y->left), get_height(y->right));
    return y;

}
Ranges Tree::items(const Node* node ){
    Ranges ranges;
    Ranges v;
    if (node->left != NULL) {
        ranges = items(node->left);
        v.insert(v.end(), ranges.begin(), ranges.end());
    }
//    v.push_back(node->ranges);
    v.insert(v.end(), node->ranges.begin(), node->ranges.end());
    if (node->right != NULL){
        ranges = items(node->right);
        v.insert(v.end(), ranges.begin(), ranges.end());
    }
    return v;
}

Ranges Tree::items(){
    Ranges v;
    if (root != NULL){
        v = items(root);
    }
    return v;
}

Ranges Tree::ranges_for_point(u128 point){
    Ranges ranges;
    ranges_for_point(root, point, ranges);
    return ranges;
}



Tree::~Tree()
{
    delete root;
}
void Tree::ranges_for_point(Node* node, u128 const &point, Ranges & ranges){

    if (node == NULL) {
        return;
    }
    if (point == node->key){

        ranges.insert(ranges.end(), node->ranges.begin(), node->ranges.end());
        return;
    }

    for (auto const& range: node->ranges){
        if (range_contains(range, point)){
            ranges.push_back(range);
        }
    }
    if (point < node->key){
        if (node->left != NULL) {
            ranges_for_point(node->left, point, ranges);
        }
        return;
    }
    if (point > node->key){
        if (node->right != NULL) {
            ranges_for_point(node->right, point, ranges);
        }
        return ;
    }

    return;
}

u128 Tree::reduce(void (*func)(u128* acc, Node* node))
{
    u128 res=0;
    reduce(root, &res, func);
    return res;
}
void Tree::reduce(Node* node, u128 *acc, void (*func)(u128 *acc, Node* node))
{
    if (node->left != 0) {
        reduce(node->left, acc, func);
    }
    func(acc, node);
    if (node->right != 0) {
        reduce(node->right, acc, func);
    }
}

std::string toString(u128 num) {
    std::string str;
    do {
        int digit = num % 10;
        str = std::to_string(digit) + str;
        num = (num - digit) / 10;
    } while (num != 0);
    return str;
}

std::ostream &operator<<(std::ostream &os, const Range &range)
{
    os << "{ " << toString(range.first) << ", " << toString(range.second) << "}";
    return os;
}

Node::~Node()
{
    delete left;
    delete right;
}
