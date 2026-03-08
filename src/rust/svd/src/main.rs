fn main() {
    let exit_code = svd_rust::adapter::run_from_stdin();
    std::process::exit(exit_code);
}
