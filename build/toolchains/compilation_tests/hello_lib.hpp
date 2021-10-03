
#pragma once

extern "C" {
    int say_hi();
    int say_howdy();
}

namespace kpns {
    class Greeting {
    public:
        virtual int greet() = 0;
    };

    struct Greeter {
        int apply(Greeting* greeting);
    };

    struct Howdy final : Greeting {
        int greet() override;
    };

    struct Hi final : Greeting {
        int greet() override;
    };
}
