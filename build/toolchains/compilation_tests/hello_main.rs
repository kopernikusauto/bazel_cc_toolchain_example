extern "C" {
    fn say_hi() -> std::os::raw::c_int;
    fn say_howdy() -> std::os::raw::c_int;
}

fn main() {
    unsafe {
        let _ = say_howdy();
        let _ = say_hi();
    }
}
