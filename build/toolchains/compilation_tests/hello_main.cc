#include "hello_lib.hpp"
#include <memory>
#include <cassert>

int main(int argc, char* argv[]) {
    int result = 0;
    kpns::Greeter greeter;

    std::unique_ptr<kpns::Greeting> greeting(new kpns::Howdy());
    assert(greeter.apply(greeting.get()) == 1);

    greeting.reset(new kpns::Hi());
    assert(greeter.apply(greeting.get()) == 2);

    return result;
}
