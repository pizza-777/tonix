pragma ton-solidity >= 0.53.0;

import "Shell.sol";

contract read is Shell {

    uint8 constant COMMAND_UNKNOWN  = 0;
    uint8 constant COMMAND_ALIAS    = 1;
    uint8 constant COMMAND_KEYWORD  = 2;
    uint8 constant COMMAND_FUNCTION = 3;
    uint8 constant COMMAND_BUILTIN  = 4;
    uint8 constant COMMAND_FILE     = 5;
    uint8 constant COMMAND_NOT_FOUND= 6;

    uint8 constant ITEM_DEFAULT = 0;
    uint8 constant ITEM_INDEXED_ARRAY = 1;
    uint8 constant ITEM_HASHMAP = 2;
    uint8 constant ITEM_INTEGER = 3;
    uint8 constant ITEM_LOWERCASE = 4;
    uint8 constant ITEM_REFERENCE = 5;
    uint8 constant ITEM_READONLY = 6;
    uint8 constant ITEM_TRACE = 7;
    uint8 constant ITEM_UPPERCASE = 8;
    uint8 constant ITEM_EXPORT = 9;

    uint8 constant TOKEN_UNKNOWN    = 0;
    uint8 constant TOKEN_COMMAND    = 1;
    uint8 constant TOKEN_BUILTIN    = 2;
    uint8 constant TOKEN_FILE       = 3;
    uint8 constant TOKEN_OPTION     = 4;
    uint8 constant TOKEN_PARAM      = 5;
    uint8 constant TOKEN_LIST       = 6;

    function b_exec(string[] e) external pure returns (uint8 ec, string out, Write[] wr) {
        string s_input = _trim_spaces(e[IS_STDIN]);
        (string[] params, string flags, ) = _get_args(e[IS_ARGS]);

        bool assign_to_array = _flag_set("a", flags);
        bool use_delimiter = _flag_set("d", flags);
        bool echo_input = !_flag_set("s", flags);
//        string delimiter = use_delimiter ? _get_option_param(s_arg, "d") : " ";
        string delimiter = " ";
        string s_attrs = assign_to_array ? "-a" : "--";

        uint16 page_index = IS_POOL;
        string page = e[page_index];

        if (assign_to_array) {
            string array_name = "REPLY";
            (string[] fields, ) = _split(s_input, delimiter);
            page = _set_var(s_attrs, array_name + "=" + _join_fields(fields, " "), page);
        } else {
            uint n_args = params.length;
            string s_split = s_input;
            for (uint i = 0; i < n_args - 1; i++) {
                (string s_head, string s_tail) = _strsplit(s_split, delimiter);
                page = _set_var(s_attrs, params[i] + "=" + s_head, page);
                if (i + 2 < n_args)
                    s_split = s_tail;
                else
                    page = _set_var(s_attrs, params[i + 1] + "=" + s_tail, page);
            }
        }
        if (e[page_index] != page)
            wr.push(Write(page_index, page, O_WRONLY));
        if (echo_input)
            out.append(s_input);
    }

    function _builtin_help() internal pure override returns (BuiltinHelp bh) {
        return BuiltinHelp(
"read",
"[-ers] [-a array] [-d delim] [-i text] [-n nchars] [-N nchars] [-p prompt] [-t timeout] [-u fd] [name ...]",
"Read a line from the standard input and split it into fields.",
"Reads a single line from the standard input, or from file descriptor FD if the -u option is supplied. The line is split\n\
into fields as with word splitting, and the first word is assigned to the first NAME, the second word to the second NAME,\n\
and so on, with any leftover words assigned to the last NAME.  Only the characters found in $IFS are recognized as word\n\
delimiters.\nIf no NAMEs are supplied, the line read is stored in the REPLY variable.",
"-a array  assign the words read to sequential indices of the array variable ARRAY, starting at zero\n\
-d delim  continue until the first character of DELIM is read, rather than newline\n\
-e        use Readline to obtain the line\n\
-i text   use TEXT as the initial text for Readline\n\
-n nchars return after reading NCHARS characters rather than waiting for a newline, but honor a delimiter if fewer than NCHARS\n\
          characters are read before the delimiter\n\
-N nchars return only after reading exactly NCHARS characters, unless EOF is encountered or read times out, ignoring any delimiter\n\
-p prompt output the string PROMPT without a trailing newline before attempting to read\n\
-r        do not allow backslashes to escape any characters\n\
-s        do not echo input coming from a terminal\n\
-u fd     read from file descriptor FD instead of the standard input",
"",
"The return code is zero, unless end-of-file is encountered, read times out (in which case it's greater than 128), a variable assignment\n\
error occurs, or an invalid file descriptor is supplied as the argument to -u.");
    }

}
