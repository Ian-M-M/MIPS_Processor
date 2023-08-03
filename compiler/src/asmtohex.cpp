#include <fstream>
#include <getopt.h>
#include <iostream>
#include <map>
#include <regex>
#include <string>
#include <unistd.h>

/**
 * Assembly to verilog-hexadecimal compiler.
 * 
 */

// Optimizer posible arguments in short format.
static constexpr char opt_string[] = "i:h?";

// Optimizer posible arguments in long format.
static constexpr struct option long_opts[] = {
    {"input", required_argument, NULL, 'i'},
    {"help", no_argument, NULL, 'h'},
    {NULL, 0, NULL, 0}
};

// Struct for showing usage of each argument of the benchmark.
static struct option_help {
    const char *long_opt, // Argument in long format.
          *short_opt,     // Argument in short format.
          *desc;          // Description of argument.
} opts_help[] = { // Array of option_help instances with every posible argument.
    {
        "--input", "-i",
        "Input file (assembly)"
    },
    {
        "--help", "-h",
        "Show program usage"
    },
    { NULL, NULL, NULL }
};

std::string file_name; // Input file.
unsigned int line_idx = 1; // Current line of the file.

enum instruction_type {R, M, B1, B2, special};

struct instruction {
    std::string bit_code;
    instruction_type type;
};

static const std::map <std::string, instruction> instructions {
    std::make_pair("NOP", instruction{"0000000", instruction_type::special}),

    std::make_pair("ADD", instruction{"0000001", instruction_type::R}),
    std::make_pair("SUB", instruction{"0000010", instruction_type::R}),
    std::make_pair("MUL", instruction{"0000011", instruction_type::R}),
    std::make_pair("OR", instruction{"0000100", instruction_type::R}),
    std::make_pair("AND", instruction{"0000101", instruction_type::R}),

    std::make_pair("LDB", instruction{"0010000", instruction_type::M}),
    std::make_pair("LDW", instruction{"0010001", instruction_type::M}),
    std::make_pair("STB", instruction{"0010010", instruction_type::B1}),
    std::make_pair("STW", instruction{"0010011", instruction_type::B1}),
    std::make_pair("MOV", instruction{"0010100", instruction_type::special}),

    std::make_pair("BEQ", instruction{"0011000", instruction_type::B1}),
    std::make_pair("JUMP", instruction{"0011001", instruction_type::special}),

    std::make_pair("ITLBWRITE", instruction{"0100010", instruction_type::special}),
    std::make_pair("DTLBWRITE", instruction{"0100000", instruction_type::special}),
    std::make_pair("IRET", instruction{"0100001", instruction_type::special}),
};

/**
 * Show usage of program.
 *
 * @param name name of the program.
 * @param exit_code exit code.
 */
static void show_usage(const char *const name, const int exit_code) {
    struct option_help *h;

    printf("usage: %s options\n", name);
    for (h = opts_help; h->long_opt; h++) {
        if (strlen(h->short_opt) == 0) {
            printf("     %s\n ", h->long_opt);
        }
        else {
            printf(" %s, %s\n ", h->short_opt, h->long_opt);
        }
        printf("    %s\n", h->desc);
    }
    printf("Example:\n");
    printf("%s -i \"fichero.asm\"\n", name);

    exit(exit_code);
}

/**
 * Prints the error ERROR_STR on line LINE_IDX of the file FILE_NAME and exit.
 * 
 * @param error_str A string containing an error.
 */
void error(const std::string &error_str) {
    std::cerr << "\033[1;39m" << file_name << ":" << line_idx << ": " << "\033[1;31m"
              << "error" << "\033[0m " << error_str << std::endl;

    exit(3);
}

/**
 * Converts the binary sequence in BIN to a hexadecimal sequence.
 * 
 * @param bin Binary sequence.
 * @return The equivalent hexadecimal sequence of the binary sequence in BIN.
 */
std::string bintohex(const std::string &bin) {

	std::string hex = "";

	for (size_t i = 0; i < bin.length(); i += 4) {

		std::string tmp = bin.substr(i, 4);

		if (!tmp.compare("0000")) {
			hex += "0";
		}
		else if (!tmp.compare("0001")) {
			hex += "1";
		}
		else if (!tmp.compare("0010")) {
			hex += "2";
		}
		else if (!tmp.compare("0011")) {
			hex += "3";
		}
		else if (!tmp.compare("0100")) {
			hex += "4";
		}
		else if (!tmp.compare("0101")) {
			hex += "5";
		}
		else if (!tmp.compare("0110")) {
			hex += "6";
		}
		else if (!tmp.compare("0111")) {
			hex += "7";
		}
		else if (!tmp.compare("1000")) {
			hex += "8";
		}
		else if (!tmp.compare("1001")) {
			hex += "9";
		}
		else if (!tmp.compare("1010")) {
			hex += "A";
		}
		else if (!tmp.compare("1011")) {
			hex += "B";
		}
		else if (!tmp.compare("1100")) {
			hex += "C";
		}
		else if (!tmp.compare("1101")) {
			hex += "D";
		}
		else if (!tmp.compare("1110")) {
			hex += "E";
		}
		else if (!tmp.compare("1111")) {
			hex += "F";
		}
		else {
			continue;
		}
	}
	return hex;
}

/**
 * Extract the first integer of STR into INTEGER.
 * 
 * If STR does not contain an integer, returns false, otherwise, returns true.
 * 
 * @param str A string that contains an integer number.
 * @param integer The first integer number in STR.
 * @return False if STR does not contain an integer, true otherwise. 
 */
bool string_to_int(std::string str, int &integer) {
    integer = -1;

    // Clean characters until a digit is found.
    size_t first_digit = str.find_first_of("0123456789.+-");
    if (first_digit == std::string::npos) {
        return false;
    }

    str = str.substr(first_digit);

    // Try to convert string to int.
    if (!(std::stringstream(str) >> integer)) {
        return false;
    }

    return true;
}

/**
 * If reg is a string that follows the structure "R{0-31}", returns a string
 * that contains the 5 bits descriptor of the register number: Ej: "00010" for
 * REG = "R2". 
 * 
 * @param reg A string that contains
 * @return std::string The binary sequence of REG.
 */
std::string parse_register(const std::string &reg) {
    int reg_int;

    if (!string_to_int(reg, reg_int) || reg_int < 0 || reg_int > 31) {
        error("invalid register \"" + reg);
    }

    return std::bitset<5>(reg_int).to_string();
}

/**
 * Returns the 25 last bits binary sequence of a type R instruction with 
 * dst = DST, src1 = SRC1 and src2 = SRC2.
 * 
 * R instruction type:
 * OPCODE DST SRC1 SRC2 0..0
 *   7b   5b   5b   5b   10b
 * 
 * @param dst dst register.
 * @param src1 src1 register.
 * @param src2 src2 register.
 * @return std::string the 25 last bits binary sequence of a type R instruction with 
 * dst = DST, src1 = SRC1 and src2 = SRC2.
 */
std::string parse_type_R(const std::string &dst, const std::string &src1, const std::string &src2) {
    return parse_register(dst) + parse_register(src1) + parse_register(src2) + "0000000000";
}

/**
 * Returns the 25 last bits binary sequence of a type B1 instruction with 
 * src1 = SRC1, src2 = SRC2 and offset = OFFSET.
 * 
 * M instruction type:
 * OPCODE DST SRC OFFSET
 *   7b   5b  5b   15b
 * 
 * @param dst dst register.
 * @param src src register.
 * @param offset Offset.
 * @return std::string the 25 last bits binary sequence of a type B1 instruction with 
 * src1 = SRC1, src2 = SRC2 and offset = OFFSET.
 */
std::string parse_type_M(const std::string &dst, const std::string &src, const std::string &offset) {
    int offset_int;
    if (!string_to_int(offset, offset_int) || offset_int < -(2E14 - 1) || offset_int > 2E14 - 1) {
        error("the offset must be > -(2E14 - 1) and < 2E14 - 1");
    }

    return parse_register(dst) + parse_register(src) + std::bitset<15>(offset_int).to_string();;
}

/**
 * Returns the 25 last bits binary sequence of a type B1 instruction with 
 * src1 = SRC1, src2 = SRC2 and offset = OFFSET.
 * 
 * B2 instruction type:
 * OPCODE OFFSETHI SRC1 SRC2 OFFSETL
 *   7b      5b     5b   5b    10b
 * 
 * @param src1 src1 register.
 * @param src2 src2 register.
 * @param offset Offset.
 * @return std::string the 25 last bits binary sequence of a type B1 instruction with 
 * src1 = SRC1, src2 = SRC2 and offset = OFFSET.
 */
std::string parse_type_B1(const std::string &src1, const std::string &src2, const std::string &offset) {
    int offset_int;
    if (!string_to_int(offset, offset_int) || offset_int < -(2E14 - 1) || offset_int > 2E14 - 1) {
        error("the offset must be > -(2E14 - 1) and < 2E14 - 1");
    }

    std::string offset_bin = std::bitset<15>(offset_int).to_string();

    std::string offsethi = offset_bin.substr(0, 5);
    std::string offsetlo = offset_bin.substr(5, 10);

    return offsethi + parse_register(src1) + parse_register(src2) + offsetlo;
}

/**
 * Returns the 25 last bits binary sequence of a type B2 instruction with 
 * src1 = SRC1 and offset = OFFSET.
 * 
 * B2 instruction type:
 * OPCODE OFFSETHI SRC1 OFFSETM OFFSETL
 *   7b      5b     5b    5b      10b
 * 
 * @param src1 src1 register.
 * @param offset Offset.
 * @return std::string the 25 last bits binary sequence of a type B2 instruction with 
 * src1 = SRC1 and offset = OFFSET.
 */
std::string parse_type_B2(const std::string &src1, const std::string &offset) {
    int offset_int;
    if (!string_to_int(offset, offset_int) || offset_int < -(2E19 - 1) || offset_int > 2E19 - 1) {
        error("the offset must be > -(2E19 - 1) and < 2E19 - 1");
    }

    std::string offset_bin = std::bitset<20>(offset_int).to_string();

    std::string offsethi = offset_bin.substr(0, 5);
    std::string offsetm = offset_bin.substr(5, 5);
    std::string offsetlo = offset_bin.substr(10, 10);

    return offsethi + parse_register(src1) + offsetm + offsetlo;
}

/**
 * Returns the 32 bits binary sequence that describes the assembly instruction
 * in LINE. If line is a comment returns an empty string. If there is a syntax error
 * in LINE, prints an error and exits.
 * 
 * @param line An line of assembly code (or a comment).
 * @return The 32 bits binary sequence that describes the assembly instruction
 * in LINE. If line is a comment returns an empty string. If there is a syntax error
 * in LINE, prints an error and exits.
 */
std::string parse_line(std::string &line) {
    if (line.empty()) {
        return "";
    }

    // Line to uppercase.
    std::transform(line.begin(), line.end(), line.begin(), ::toupper);
    
    // Can be an instruction.
    if (std::regex_match(line, std::regex("^[ ]*[A-Z]+.*;[ ]*(//.*$|$)"))) {
        std::string line_spaced = line;

        std::replace(line_spaced.begin(), line_spaced.end(), ',', ' '); // replace all ',' to ' '
        std::replace(line_spaced.begin(), line_spaced.end(), ';', ' '); // replace all ';' to ' '

        // Split line_spaced into words.
        std::vector<std::string> instr_split;
        std::istringstream iss(line_spaced);
        for (std::string word; iss >> word;) {
            instr_split.push_back(word);
        }

        std::string &op = instr_split[0];

        const instruction *instr;

        try {
            instr = &instructions.at(op);
        }
        catch (const std::out_of_range &e) {
            error("instruction \"" + op + "\" does not exist.");
        }

        std::string bit_code = instr->bit_code;

        // Type R
        if (instr->type == instruction_type::R &&
                std::regex_match(line, std::regex("^[ ]*[A-Z]+[ ]+"
                                 "R[0-9]+[ ]*,[ ]*"
                                 "R[0-9]+[ ]*,[ ]*"
                                 "R[0-9]+[ ]*;"
                                 ".*$"))) {
            try {
                bit_code += parse_type_R(instr_split.at(1), instr_split.at(2), instr_split.at(3));
            }
            catch (const std::out_of_range &e) {
                error("bad arguments in instruction \"" + op + "\"");
            }
        }
        // Type M
        else if (instr->type == instruction_type::M  &&
                 std::regex_match(line, std::regex("^[ ]*[A-Z]+[ ]+"
                                  "R[0-9]+[ ]*,[ ]*"
                                  "R[0-9]+[ ]*,[ ]*"
                                  "[-+]?[0-9]+[ ]*;"
                                  ".*$"))) {
            try {
                bit_code += parse_type_M(instr_split.at(1), instr_split.at(2), instr_split.at(3));
            }
            catch (const std::out_of_range &e) {
                error("bad arguments in instruction \"" + op + "\"");
            }
        }
        // Type B1
        else if (instr->type == instruction_type::B1 &&
                 std::regex_match(line, std::regex("^[ ]*[A-Z]+[ ]+"
                                  "R[0-9]+[ ]*,[ ]*"
                                  "R[0-9]+[ ]*,[ ]*"
                                  "[-+]?[0-9]+[ ]*;"
                                  ".*$"))) {

            try {
                bit_code += parse_type_B1(instr_split.at(1), instr_split.at(2), instr_split.at(3));
            }
            catch (const std::out_of_range &e) {
                error("bad arguments in instruction \"" + op + "\"");
            }
        }
        // Type B2
        else if (instr->type == instruction_type::B2 &&
                 std::regex_match(line, std::regex("^[ ]*[A-Z]+[ ]+"
                                  "R[0-9]+[ ]*,[ ]*"
                                  "[-+]?[0-9]+[ ]*;"
                                  ".*$"))) {

            try {
                bit_code += parse_type_B2(instr_split.at(1), instr_split.at(2));
            }
            catch (const std::out_of_range &e) {
                error("bad arguments in instruction \"" + op + "\"");
            }
        }
        // NOP
        else if (instr->type == instruction_type::special && op == "NOP"  &&
                 std::regex_match(line, std::regex("^[ ]*NOP[ ]*;.*$"))) {

            bit_code += "0000000000000000000000000";
        }
        // JUMP
        else if (instr->type == instruction_type::special && op == "JUMP"  &&
                 std::regex_match(line, std::regex("^[ ]*JUMP[ ]+[-+]?[0-9]+[ ]*;.*$"))) {

            try {
                bit_code += parse_type_B2("0", instr_split.at(1));
            }
            catch (const std::out_of_range &e) {
                error("bad arguments in instruction \"" + op + "\"");
            }
        }
        // MOV
        else if (instr->type == instruction_type::special && op == "MOV" &&
                 std::regex_match(line, std::regex("^[ ]*MOV[ ]+"
                                                   "R[0-9]+[ ]*,[ ]*"
                                                   "RM[0-9]+[ ]*;.*$"))) {

            try {
                std::string &rmx = instr_split.at(2);
                if (rmx != "RM0" && rmx != "RM1" && rmx != "RM2" && rmx != "RM4") {
                    error("RMX can only be {0, 1, 2, 4}");
                }

                bit_code += parse_type_M(instr_split.at(1), instr_split.at(2), "0");
            }
            catch (const std::out_of_range &e) {
                error("bad arguments in instruction \"" + op + "\"");
            }
        }
        // TLBWRITE
        else if (instr->type == instruction_type::special && (op == "ITLBWRITE"
                || op == "DTLBWRITE") &&
                 std::regex_match(line, std::regex("^[ ]*[ID]TLBWRITE[ ]+"
                                  "R[0-9]+[ ]*,[ ]*"
                                  "R[0-9]+[ ]*;.*$"))) {
        
            try {
                bit_code += parse_type_B1(instr_split.at(1), instr_split.at(2), "0");
            }
            catch (const std::out_of_range &e) {
                error("bad arguments in instruction \"" + op + "\"");
            }                    
        }
        // IRET
        else if (instr->type == instruction_type::special && op == "IRET" &&
                 std::regex_match(line, std::regex("^[ ]*IRET[ ]*;.*$"))) {

            try {
                bit_code += parse_type_B1("0", "0", "0");
            }
            catch (const std::out_of_range &e) {
                error("bad arguments in instruction \"" + op + "\"");
            }
        }
        else {
            error("syntax error.");
        }
        return bit_code;
    }
    // Not a comment.
    else if (!std::regex_match(line, std::regex("^[ ]*//.*$")) &&
             !std::regex_match(line, std::regex("^[ ]+$"))) {
        error("unrecognized instruction.");
    }

    return "";
}

/**
 * Transforms the file FILE_NAME from assembly to verilog hexadecimal.
 * 
 */
void compile() {
    std::ifstream file_stream;
    file_stream.open(file_name);

    if (!file_stream.is_open()) {
        throw std::runtime_error("Could not open file");
    }

    std::string line;
    while (getline(file_stream, line)) {
        std::string instr = parse_line(line);

        line_idx++;

        if (instr.empty()) {
            continue;
        }

        std::cout << bintohex(instr) << std::endl;
    }

    file_stream.close();
}

int main(const int argc, char *const argv[]) {
    if (argc < 2) {
        show_usage(argv[0], 0);
    }

    // Read options.
    while (1) {
        int option = getopt_long(argc, argv, opt_string, long_opts, NULL);
        if (option == -1) {
            break;
        }

        switch (option) {
            // Input file.
            case 'i':
                file_name = std::string(optarg);
                if (access(optarg, R_OK) == -1) {
                    std::cerr << "ERROR: the input file doesn't exist"
                              << " or you don't have permissions to read from it\n\n";
                    exit(EXIT_FAILURE);
                }
                break;
            // Help.
            case 'h':
                show_usage(argv[0], 0);
                break;

            default:
                show_usage(argv[0], 1);
        }
    }

    if (file_name.empty()) {
        std::cout << "ERROR: the input file has not been specified\n\n";
        exit(EXIT_FAILURE);
    }

    compile();

    return EXIT_SUCCESS;
}