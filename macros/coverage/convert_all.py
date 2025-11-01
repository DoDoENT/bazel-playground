from jinja2 import Environment, FileSystemLoader
import argparse
import os

from convert import convert


class Arguments:
    def __init__(self):
        pass


forbidden_folders = ['testlogs', '.runfiles', "external"]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Convert llvm coverage data into a browsable html report.')

    parser.add_argument('-v', '--verbose', dest='verbose', action='store_const', const=True, default=False)
    parser.add_argument('-s', '--src', dest='srcprefix', default='')
    parser.add_argument('-i', '--ignore', dest='srcignores', nargs='+', default=[])
    parser.add_argument('-p', '--profdata', dest='data', default='default.profdata')
    parser.add_argument('-o', '--output', dest='output', default='coverage')
    parser.add_argument('-t', '--title', dest='title', default='Index')
    parser.add_argument('folder', metavar='FOLDER')

    args = parser.parse_args()

    file_list = []

    for dirpath, _, filenames in os.walk(args.folder):
        for file in filenames:
            filepath = os.path.join(dirpath, file)

            if args.verbose:
                print('checking file: {}'.format(filepath))

            # Skip files with extensions
            if file.find('.') >= 0:
                continue

            try:
                with open(filepath, 'rb') as f:
                    is_elf = f.read(4) == b'\x7fELF'
            except IOError:
                is_elf = False

            if (not is_elf or os.path.isdir(filepath) or
                    any(folder in filepath for folder in forbidden_folders)):
                continue
            print('processing file: {}'.format(filepath))

            # prepare local args
            local_args = Arguments()
            local_args.verbose = args.verbose
            local_args.srcprefix = args.srcprefix
            local_args.srcignores = args.srcignores
            local_args.data = args.data
            local_args.title = file
            local_args.output = os.path.join(args.output, file)
            local_args.executable = filepath

            try:
                convert(local_args)
                file_list.append(file)
            except Exception:
                print('  error processing file: {}'.format(filepath))

    j2_env = Environment(loader=FileSystemLoader(os.path.dirname(os.path.abspath(__file__))))

    if args.verbose:
        print('rendering master index file...')

    j2_env.get_template('master_template.html').stream(file_list=file_list,
                                                       title=args.title).dump(args.output + '/index.html')

