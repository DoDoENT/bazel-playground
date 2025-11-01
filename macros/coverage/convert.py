# coding=utf-8

import subprocess
import json
import os
import fnmatch
import multiprocessing
from jinja2 import Environment, FileSystemLoader
import argparse


def percentcolor(p):
    if p <= 25:
        return 'red'
    elif p == 100:
        return 'green'
    else:
        return 'black'


def child(i, total, f, args):

    if args.verbose:
        print('{}/{} -- {}%'.format(i + 1, total, round(float(i) / float(total) * 100., 2)))

    out = open('{}/files/{}.html'.format(args.output, os.path.basename(f)), 'w')

    p = subprocess.Popen(['llvm-cov', 'show',
                          '--path-equivalence=/proc/self/cwd,{}'.format(args.srcprefix),
                          '-format=html', '-Xdemangler', 'c++filt', '-Xdemangler', '-n', '-instr-profile',
                          args.data, args.executable, f], stdout=out)

    p.wait()

    out.flush()


def convert(args):
    if args.verbose:
        print('exporting with data {} for executable {}…'.format(args.data, args.executable))

    process = subprocess.Popen(['llvm-cov', 'export', '-instr-profile', args.data, args.executable],
                               stdout=subprocess.PIPE)

    prefdata = json.loads(process.communicate()[0])

    data = prefdata['data'][0]

    ignored = 0

    # add 'ignore' property to all items matching ignore list
    for f in data['files']:
        for ignore in args.srcignores:
            if fnmatch.fnmatch(f['filename'].replace(args.srcprefix, ''), ignore):
                f['ignore'] = True
                ignored = ignored + 1
        f['short_name'] = os.path.basename(f['filename'])

    if args.verbose:
        print('ignoring {} files'.format(ignored))

    j2_env = Environment(loader=FileSystemLoader(os.path.dirname(os.path.abspath(__file__))))

    if args.verbose:
        print('rendering index…')

    if not os.path.exists(args.output + '/files'):
        os.makedirs(args.output + '/files')

    j2_env.get_template('template.html').stream(data=data,
                                                title=args.title,
                                                srcprefix=args.srcprefix,
                                                percentcolor=percentcolor).dump(args.output + '/index.html')

    if args.verbose:
        print('rendering files…')

    pool = multiprocessing.Pool(multiprocessing.cpu_count())

    for i, f in enumerate(data['files']):
        pool.apply_async(child, (i, len(data['files']), f['filename'],  args))

    pool.close()
    pool.join()


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Convert llvm coverage data into a browsable html report.')

    parser.add_argument('-v', '--verbose', dest='verbose', action='store_const', const=True, default=False)
    parser.add_argument('-s', '--src', dest='srcprefix', default='')
    parser.add_argument('-i', '--ignore', dest='srcignores', nargs='+', default=[])
    parser.add_argument('-p', '--profdata', dest='data', default='default.profdata')
    parser.add_argument('-o', '--output', dest='output', default='coverage')
    parser.add_argument('-t', '--title', dest='title', default='Index')
    parser.add_argument('executable', metavar='EXECUTABLE')

    args = parser.parse_args()
    convert(args)


