#include <iostream>
#include "ctree.h"
#include <tuple>

using namespace std;

void test_destructor(){
    Tree tree = Tree();
    tree.insert({100, 105});
    tree.insert({106, 110});
    tree.insert({111, 116});
    tree.insert({120, 125});
    tree.insert({126, 130});
    tree.insert({95, 99});
    tree.insert({90, 94});
    tree.insert({80, 90});
    tree.insert({70, 80});
}

int main()
{
    u128 test = 2;
    test = (test << 127) - 1;
    cout << "big integer " << toString(test) << endl;

    Range r = {100, 502};
    cout << r << " contains value:  2 " << range_contains(r, 150) << endl;

    Node * node1 = create_node(r);

    node1->left = create_node({1102, 1150});
    node1->right = create_node(Range{1102, 1150});
    cout << "check child node key " <<toString(node1->left->key) << endl;


    Tree tree = Tree();
    tree.insert({100, 105});
    tree.insert({106, 110});
    tree.insert({111, 116});
    tree.insert({120, 125});
    tree.insert({126, 130});
    tree.insert({95, 99});
    tree.insert({90, 94});
    tree.insert({80, 90});
    tree.insert({70, 80});
    vector walk_ranges = tree.items();
    for(auto const& range: walk_ranges){
         cout << range << ", ";

        cout<<endl;
    }
//    auto l = [](auto acc, auto node) { *acc = std::max((u128)*acc, (u128)node->ranges.size());};
//    u128 sum = tree.reduce(l);
//    cout << "sum" << toString(sum)<<endl;
    u128 point= 100;
    Ranges ranges = tree.ranges_for_point(point);
    for(auto const& range: ranges){
        cout << "ranges for " << toString(point) <<": " << range << ", " << endl;
    }

    tree = Tree();
    point= 100;
    ranges = tree.ranges_for_point(point);
    for(auto const& range: ranges){
        cout << "ranges for " << toString(point) <<": " << range << ", " << endl;
    }

    test_destructor();
    return 0;
}
