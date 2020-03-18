#ifndef CTREE_H
#define CTREE_H
#include <vector>
#include <tuple>
#include <utility>
#include <forward_list>


typedef  __uint128_t u128;
using namespace std;


typedef pair<u128, u128> Range;
//struct Range {
//    u128 first;
//    u128 last;
//};
typedef vector<Range> Ranges;
bool range_contains(const Range &range, const u128 value);



struct Node {
    Node * left;
    Node * right;
    u128 key;
    unsigned char height;
    Ranges ranges;
    ~Node();
};

class Tree {
private:
    Node* root;
    Node* insert(Node*, const Range&);
    Ranges items(const Node*);
    signed char get_balance(const Node *node);
    signed char get_height(const Node *node);
    Node* rotate_left(Node*);
    Node* rotate_right(Node*);
    void ranges_for_point(Node*, const u128 &, Ranges &ranges);
    void reduce(Node* node, u128 *acc, void (*func)(u128 *acc, Node* node));

public:
    Tree();
    ~Tree();
    void insert(const Range&);
    Ranges items();
    Ranges ranges_for_point(u128);
    u128 reduce(void (*func)(u128* acc, Node* node));

};

Node* create_node(const Range &);

string toString(u128);
ostream& operator<<(std::ostream&, const Range&);





#endif // CTREE_H
