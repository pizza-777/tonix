pragma ton-solidity >= 0.53.0;

import "Utility.sol";

contract dirname is Utility {

    function exec(string[] e) external pure returns (uint8 ec, string out, string err) {
        ec = EXECUTE_SUCCESS;
        err = "";
        (string[] args, , ) = _get_args(e[IS_ARGS]);
    /*function exec(InputS input) external pure returns (string out) {
        (, string[] args, ) = input.unpack();*/
        for (string s: args) {
            (string dir, ) = _dir(s);
            out += dir + "\n";
        }
    }

    function _command_info() internal override pure returns (string command, string purpose, string synopsis, string description, string option_list, uint8 min_args, uint16 max_args, string[] option_descriptions) {
        return ("dirname", "strip last component from file name", "[OPTION] NAME...",
            "Output NAME with its last non-slash component and trailing slashes removed; if NAME contains no /'s, output '.' (meaning the current directory).",
            "z", 1, M, [
            "end each output line with NUL, not newline"]);
    }

    function _command_help() internal override pure returns (CommandHelp) {
        return CommandHelp(
"dirname",
"[OPTION] NAME...",
"strip last component from file name",
"Output NAME with its last non-slash component and trailing slashes removed; if NAME contains no /'s, output '.' (meaning the current directory).",
"-z     end each output line with NUL, not newline",
"",
"Written by Boris",
"",
"",
"0.01");
    }
}
