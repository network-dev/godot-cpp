#!/usr/bin/env python

from argparse import ArgumentParser

from binding_generator import generate_bindings, print_file_list


def main():
    parser = ArgumentParser()
    subparsers = parser.add_subparsers(dest="command")

    parser_print = subparsers.add_parser("print")
    parser_print.add_argument("-o", "--output", required=True)
    parser_print.add_argument("-a", "--api", required=True)

    parser_generate = subparsers.add_parser("generate")
    parser_generate.add_argument("-o", "--output", required=True)
    parser_generate.add_argument("-a", "--api", required=True)
    parser_generate.add_argument("-b", "--arch-bits", required=True)
    parser_generate.add_argument("-p", "--precision", default="single")

    args = parser.parse_args()

    if args.command == "print":
        print_file_list(api_filepath=args.api, output_dir=args.output, headers=True, sources=True)
    elif args.command == "generate":
        generate_bindings(
            api_filepath=args.api,
            use_template_get_node=True,
            bits=args.arch_bits,
            precision=args.precision,
            output_dir=args.output,
        )


if __name__ == "__main__":
    main()
