
#include "hello_lib.hpp"
#include <iostream>
#include <memory>
#include <cassert>

int say_hi() {
    std::unique_ptr<kpns::Greeting> greeting(new kpns::Hi());
    kpns::Greeter greeter;
    return greeter.apply(greeting.get());
}

int say_howdy() {
    std::unique_ptr<kpns::Greeting> greeting(new kpns::Howdy());
    kpns::Greeter greeter;
    return greeter.apply(greeting.get());
}


namespace kpns {
    int Greeter::apply(Greeting* greeting) {
        assert(greeting != nullptr);
        return greeting->greet();
    }

    int Howdy::greet() {
        std::cout << "Howdy!" << std::endl;
        return 1;
    }

    int Hi::greet() {
        std::cout << "Hi!" << std::endl;
        return 2;
    }
}
