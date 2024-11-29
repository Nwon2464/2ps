#include <algorithm>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <regex>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

using namespace std;

// Structure to hold each data record
struct DataRecord {
    int id;
    int product_id;
    string name;
    double amount;
    string created_date;
    string category;
};

// Function to trim whitespace from both ends of a string
string trim(const string &str) {
    size_t first = str.find_first_not_of(" \t\r\n");
    size_t last = str.find_last_not_of(" \t\r\n");
    if (first == string::npos || last == string::npos)
        return "";
    return str.substr(first, last - first + 1);
}

// Function to split a string by a delimiter and return a vector of tokens
vector<string> split(const string &line, char delimiter = ',') {
    vector<string> tokens;
    string token;
    bool in_quotes = false;
    for (char ch : line) {
        if (ch == '\"') {
            in_quotes = !in_quotes;
        } else if (ch == delimiter && !in_quotes) {
            tokens.push_back(trim(token));
            token.clear();
        } else {
            token += ch;
        }
    }
    tokens.push_back(trim(token));
    return tokens;
}

// Function to check if a string is a valid number (integer or float)
bool isNumber(const string &str) {
    regex numberRegex("^-?\\d*\\.?\\d+$");
    return regex_match(str, numberRegex);
}

// Function to fix the date format to YYYY-MM-DD
bool fix_date_format(const string &date, string &corrected_date) {
    // Define a regex pattern for a valid date format: YYYY-MM-DD
    regex valid_pattern("^\\d{4}-\\d{2}-\\d{2}$");

    // Check if the date already matches the valid format
    if (regex_match(date, valid_pattern)) {
        corrected_date = date;
        return true;
    }

    // Replace all non-digit characters with '-'
    regex invalid_separators("[^0-9]");
    string temp_date = regex_replace(date, invalid_separators, "-");

    // Extract the first 10 characters (YYYY-MM-DD)
    if (temp_date.size() >= 10) {
        corrected_date = temp_date.substr(0, 10);
        // Validate the corrected date format
        if (regex_match(corrected_date, valid_pattern)) {
            return true;
        }
    }

    return false;
}

// Function to validate the 'name' field
bool valid_string(const string &str) {
    // Check if the string is exactly "NaN or NULL"
    if (str == "NaN" || str == "NULL") {
        return false;
    }

    // Check for gibberish using a regex. Define "gibberish" as anything that is not readable
    // Readable string: letters, numbers, spaces, and basic punctuation
    regex readableRegex("^[a-zA-Z0-9 ,.!?]+$");
    return regex_match(str, readableRegex);
}

// Function to determine the category based on amount
string determine_category(double amount) {
    return (amount >= 50.0) ? "High" : "Low";
}

// Function to parse the header line and map header names to their indices
unordered_map<string, int> parse_header(const vector<string> &headers) {
    unordered_map<string, int> header_map;    
    for (size_t i = 0; i < headers.size(); ++i) {
        header_map[trim(headers[i])] = static_cast<int>(i);
    }
    return header_map;
}

string output_str(const vector<string> &S) {
    string output_str = "";
    for (int i = 0; i < S.size(); i++) {

        output_str += S[i];
        if (i == S.size() - 1)
            continue;
        output_str += ", ";
    };
    return output_str;
}

int main() {
    // Prompt user for output filenames
    string valid_records_filename;
    string data_changes_filename;
    
    cout << "Enter the desired filename for valid records (e.g., valid_records.csv): ";
    getline(cin, valid_records_filename);
    if (valid_records_filename.empty()) {
        valid_records_filename = "valid_records.csv"; // Default name if user provides none
        cout << "No input provided. Using default filename: " << valid_records_filename << "\n";
    }

    cout << "Enter the desired filename for data changes log (e.g., data_changes.log): ";
    getline(cin, data_changes_filename);
    if (data_changes_filename.empty()) {
        data_changes_filename = "data_changes.log"; // Default name if user provides none
        cout << "No input provided. Using default filename: " << data_changes_filename << "\n";
    }

    // Open input CSV file
    ifstream infile("spool.csv");
    if (!infile.is_open()) {
        cerr << "Error: Could not open file spool.csv" << endl;
        return 1;
    }
    cout << "Opened file spool.csv" << endl;

    // Open log file
    ofstream logFile(data_changes_filename);
    if (!logFile.is_open()) {
        cerr << "Error: Could not create log file " << data_changes_filename << endl;
        return 1;
    }

    // Vector to store valid records
    vector<DataRecord> valid_records;
    string line;
    unordered_map<string, int> header_map;
    bool header_parsed = false;

    while (getline(infile, line)) {
        // Trim the line to remove leading and trailing whitespaces
        string trimmed_line = trim(line);
        
        // Skip empty lines
        if (trimmed_line.empty()) {
            continue;
        }

        // Skip SQL commands or separators
        if (trimmed_line.find("SQL>") == 0 || trimmed_line.find("---") == 0) {
            continue;
        }

        // Parse header
        if (!header_parsed && trimmed_line.find("ID") == 0) {
            vector<string> headers = split(line);
            header_map = parse_header(headers);
            header_parsed = true;
            continue;
        }

        // Process data lines
        if (isdigit(trimmed_line[0])) {
            vector<string> data = split(line);
            // Ensure that the number of fields matches the header
            if (data.size() < header_map.size()) {
                continue;
            }

            try {
                // Extract fields using header_map
                string id_str = data[header_map["ID"]];
                string product_id_str = data[header_map["PRODUCT_ID"]];
                string name_str = data[header_map["PRODUCT_NAME"]];
                string amount_str = data[header_map["AMOUNT"]];                
                string created_date_str = data[header_map["DATES"]];

                bool record_valid = true;

                // Validate ID
                if (id_str.empty() || !isNumber(id_str)) {
                    logFile << "Invalid ID. Line: " << output_str(split(trimmed_line)) << "\n";
                    record_valid = false;
                }
                
                int id = record_valid ? stoi(id_str) : -1;

                // Validate Product ID
                if (product_id_str.empty() || !isNumber(product_id_str)) {
                    logFile << "Record ID " << id << ": Invalid Product ID. Line: " << output_str(split(trimmed_line)) << "\n";
                    record_valid = false;
                }
                
                int product_id = record_valid ? stoi(product_id_str) : -1;

                // Validate Name
                if (name_str.empty() || !valid_string(name_str)) {
                    logFile << "Record ID " << id << ": Invalid Name ('" << name_str << "'). Line: " << output_str(split(trimmed_line)) << "\n";
                    record_valid = false;
                }
               
                // Validate Amount
                if (amount_str.empty() || !isNumber(amount_str)) {
                    logFile << "Record ID " << id << ": Invalid Amount. Line: " << output_str(split(trimmed_line)) << "\n";
                    record_valid = false;
                }
                double amount = record_valid ? stod(amount_str) : 0.0;

                if (record_valid && amount < 0.0) {
                    logFile << "Record ID " << id << ": Negative Amount (" << fixed << setprecision(3) << amount
                            << "). Line: " << output_str(split(trimmed_line)) << "\n";
                    record_valid = false;
                }

                // Validate and format Created Date
                string corrected_date;
                if (created_date_str.empty() || !fix_date_format(created_date_str, corrected_date)) {
                    logFile << "Record ID " << id << ": Invalid Created Date ('" << created_date_str
                            << "'). Line: " << output_str(split(trimmed_line)) << "\n";
                    record_valid = false;
                } else if (corrected_date != created_date_str) {
                    logFile << "Record ID " << id << ": Corrected Created Date from '" << created_date_str << "' to '" << corrected_date << "'.\n";
                }


                // If record is valid, add to valid_records
                if (record_valid) {
                    string category = determine_category(amount);
                    DataRecord record = {id, product_id, name_str, amount, corrected_date, category};     
                    
                    valid_records.push_back(record);
                }
            } catch (const exception &e) {
                logFile << "Exception while parsing line: " << trimmed_line << "\nException: " << e.what() << "\n";
                continue;
            }
        }
    }

    infile.close();
    logFile.close();

    // Open output file for valid records
    ofstream outputFile(valid_records_filename);
    if (!outputFile.is_open()) {
        cerr << "Error: Could not create output file " << valid_records_filename << endl;
        return 1;
    }

    // Write header to the output file
    //outputFile << "ID,PRODUCT_ID,PRODUCT_NAME,AMOUNT,CREATED_DATE,CATEGORY\n";

    // Set formatting for amount to have exactly three digits after the decimal point
    outputFile << fixed << setprecision(3);

    for (const auto &record : valid_records) {
        outputFile << record.id << "," << record.product_id << "," << record.name << "," << record.amount << "," << record.created_date << ","
                   << record.category << "\n";
    }

    outputFile.close();

    cout << "Processing complete.\n";
    cout << "Valid records written to '" << valid_records_filename << "'.\n";
    cout << "Changes and errors logged in '" << data_changes_filename << "'.\n";

    return 0;
}

