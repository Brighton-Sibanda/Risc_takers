# python script for converting an asm dump from creatorsim to little endian hex

import re

def convert_to_little_endian(dump):
    hex_instruction_pattern = re.compile(r'^[0-9A-Fa-f]{2} [0-9A-Fa-f]{2} [0-9A-Fa-f]{2} [0-9A-Fa-f]{2}')

    little_endian_instructions = []

    for line in dump.split('\n'):
        match = hex_instruction_pattern.search(line)
        if match:
            instruction = match.group().replace(' ', '')
            little_endian_instruction = ''.join(reversed([instruction[i:i+2] for i in range(0, len(instruction), 2)]))
            little_endian_instructions.append(little_endian_instruction)

    return little_endian_instructions

def read_dump_file(file_path):
    with open(file_path, 'r') as file:
        dump = file.read()
    return dump

def write_to_file(file_path, data):
    with open(file_path, 'w') as file:
        for line in data:
            file.write(line + '\n')

dump_file_path = 'gcd.txt'
dump_contents = read_dump_file(dump_file_path)

little_endian_instructions = convert_to_little_endian(dump_contents)

output_file_path = 'gcd.hex'
write_to_file(output_file_path, little_endian_instructions)

print(f"Little endian instructions have been written to {output_file_path}")
