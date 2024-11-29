#include <algorithm>
#include <array>
#include <cassert>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <map>
#include <numeric>
#include <queue>
#include <random>
#include <set>
#include <string>
#include <unordered_set>
#include <utility>
#include <fstream>
#include <sstream>
#include <vector>
using namespace std;

// clang-format off
template<typename A, typename B> ostream& operator<<(ostream &os, const pair<A, B> &p) { return os << '(' << p.first
<< ", " << p.second << ')'; } template<typename T_container, typename T = typename enable_if<!is_same<T_container,
string>::value, typename T_container::value_type>::type> ostream& operator<<(ostream &os, const T_container &v) { os
<< '{'; string sep; for (const T &x : v) os << sep << x, sep = ", "; return os << '}'; }

template<typename T_vector>void output_vector(const T_vector &v, bool add_one = false, int start = -1, int end = -1)
{if (start < 0) start = 0; if (end < 0) end = int(v.size()); for (int i = start; i < end; i++) cout << v[i] +
(add_one ? 1 : 0) << (i < end - 1 ? ' ' : '\n');}

void dbg_out() { cerr << endl; }
template<typename Head, typename... Tail> void dbg_out(Head H, Tail... T) { cerr << ' ' << H; dbg_out(T...); }
#ifdef LOCAL
#define dbg(...) cerr <<"\e[38;5;075m" << "(" << #__VA_ARGS__ << "):" << "\e[39m", dbg_out(__VA_ARGS__)
#else
#define dbg(...)
#endif

auto random_address = [] { char *p = new char; delete p;return uint64_t(p);};
const uint64_t SEED = chrono::steady_clock::now().time_since_epoch().count() * (random_address() | 1);
mt19937_64 rng(SEED);
// clang-format on
// [lower,upper]
double real_rng(double a = 0, double b = 1) {
    assert(a <= b);
    return uniform_real_distribution<double>(a, b)(rng);
}
// uniformly distribute integer number in [a,b]
int64_t uniform_rng(int64_t a = 0, int64_t b = 1) {
    assert(a <= b);
    return uniform_int_distribution<int64_t>(a, b)(rng);
}

// log uniform distributed integer in [a,b]. P(a) > P(a+1) > ... > P(b).
int64_t log_rng(int64_t a, int64_t b) {
    assert(a <= b);
    double min_val = double(a) - 0.5, max_val = double(b) + 0.5;

    int64_t x = int64_t(round(min_val - 1 + exp(real_rng(0, log(max_val - min_val + 1)))));

    static const int unchanged_bit = 30;

    if (uint64_t(x - a) >= 1LLU << unchanged_bit) {
        x ^= rng() >> (__builtin_clzll(x - a) + unchanged_bit);
    }
    return min(max(x, a), b);
}

// return +1 or -1 with 50% probability
int sign_rng() {
    return real_rng() < 0.5 ? +1 : -1;
}
bool uniform_bool() {
    return uniform_rng(0, 1) == 1;
}

// random choice from [0.0, 1.0]

// random choice non-empty sub-interval from interval [lower, upper)
// equal: random choice 2 disjoint elements from [lower, upper]

pair<int64_t, int64_t> uniform_pair(int64_t lower, int64_t upper) {
    assert(upper - lower >= 1);
    int64_t a, b;
    do {
        a = uniform_rng(lower, upper);
        b = uniform_rng(lower, upper);
    } while (a == b);
    if (a > b)
        std::swap(a, b);
    return {a, b};
}

vector<int64_t> perm_rng(int64_t n) {
    vector<int64_t> perm(n);
    iota(perm.begin(), perm.end(), 1); // start from 1 to n
    // if you want neg vals, -n
    shuffle(perm.begin(), perm.end(), rng);
    return perm;
}
vector<int64_t> choice_rng(int64_t n, int64_t lower, int64_t upper) {
    assert((n) <= upper - lower + 1);
    set<int64_t> res;
    while (res.size() < n)
        res.insert(uniform_rng(lower, upper));
    return {res.begin(), res.end()};
}
// string [a to z]
string lower_string(int64_t n) {
    string res = "";
    for (size_t i = 0; i < n; i++) {
        res += uniform_rng('a', 'z');
    }
    return res;
}
bool log_mode = false;

vector<string> process_args(int argc, char **argv) {
    vector<string> args;
    for (int i = 1; i < argc; i++) {
        string arg = argv[i];
        if (arg.find("-log") != string::npos) {
            log_mode = true;

        } else {
            args.push_back(arg);
        }
    }
    return args;
}

// uniformly distribute real number in [a,b)
struct custom_hash {
    static uint64_t splitmix64(uint64_t x) {
        // http://xorshift.di.unimi.it/splitmix64.c
        x += 0x9e3779b97f4a7c15;
        x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9;
        x = (x ^ (x >> 27)) * 0x94d049bb133111eb;
        return x ^ (x >> 31);
    }

    size_t operator()(pair<uint64_t, uint64_t> x) const {
        static const uint64_t FIXED_RANDOM = chrono::steady_clock::now().time_since_epoch().count();
        return splitmix64(x.first + FIXED_RANDOM) ^ (splitmix64(x.second + FIXED_RANDOM) >> 1);
    }
};

int main(int argc, char **argv) {
    vector<string> args = process_args(argc, argv);

    cerr << "SEED = " << SEED << endl;
    // assert(args.size() >= 1);
    // int64_t N = stoll(args[0])

    int N = 10;
    ofstream outputFile("spool.csv");
    outputFile << "ID" << "," << "product_id" << "," << "product_name" << "," << "amount" << "," << "dates" << '\n';

    for (int i = 0; i < N; i++) {
        int id = uniform_rng(1, N);
        int product_id = uniform_rng(1, N);
        int M = uniform_rng(5, 8);

        string product_name = "Product Name: " + lower_string(M);
        int d = uniform_rng(1, 1e9);
        int e = uniform_rng(1, 9999);
        string amount = to_string(d) + "." + to_string(e);

        string dates = to_string(uniform_rng(1950, 2024));
        bool na = uniform_bool();
        if (na) {
            if (uniform_bool()) {
                dates += '*';
            } else {
                dates += '/';
            }
        } else {
            dates += '-';
        }
        string month = to_string(uniform_rng(1, 12));
        if (month.length() == 1) {
            month = '0' + month;
        }
        dates += month;
        if (na) {
            if (uniform_bool()) {
                dates += '*';
            } else {
                dates += '/';
            }
        } else {
            dates += '-';
        }
        string days = to_string(uniform_rng(1, 31));
        if (days.length() == 1) {
            days = '0' + days;
        }
        dates += days;

        outputFile << id << "," << product_id << "," << product_name << "," << amount << "," << dates << '\n';
    }
    outputFile.close();

    
    return 0;
}


// CREATE TABLE new_products (
//     ID           NUMBER,
//     PRODUCT_ID   NUMBER,
//     PRODUCT_NAME VARCHAR2(50), 
//     AMOUNT       VARCHAR2(30),
//     DATES        VARCHAR2(15),
//     CATEGORY     VARCHAR2(20)
// );