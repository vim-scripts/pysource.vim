" pysource.vim - Find python source intelligently
" Maintainer: Colin Wood <cwood06 at gmail dot com>
" Version: 1.0.0
" License: Same as Vim

if has('g:pysource_loaded')
    finish
endif

let g:pysource_loaded = 1

if !has('python')
    echoerr 'Missing python'
    finish
endif

function! s:FindPythonSource()
python << EOF
import vim
import inspect
import os
import sys
import re

class SourceFinder(object):

    def get_import_file(self, module, attributes=None, **kwargs):

        try:
            new_object = __import__(module, globals(), locals(), attributes,
                                    -1)
        except Exception, e:

            if not hasattr(self, 'relative'):
                return e

        if hasattr(self, 'relative'):
            if os.path.exists(os.path.join(self.relative_path, module+'.py')):
                return os.path.join(self.relative_path, module+'.py')
            else:
                return ''

        from_file = inspect.getfile(new_object)

        if from_file.endswith('.pyc'):
            return from_file[:-1]
        elif from_file.endswith('.py'):
            return from_file

    def get_line(self):
        return vim.current.line

    def find_import(self):
        line = self.get_line()
        parts = line.split(' ', 3)

        try:
            module = parts[1]
        except KeyError:
            module = None

        if module.startswith('.'):
            paths = module.split('.')
            module = paths[-1]
            path = '.'.join(paths[0:-1])+'.'

            if path not in sys.path:
                sys.path.append(path)

            self.relative = True
            self.relative_path = path

        try:
            attributes = parts[3]
            attributes = attributes.split(',')
        except KeyError:
            attributes = []

        for i, attribute in enumerate(attributes):
            attributes[i] = re.sub(r'\s', '', attribute)

        return self.get_import_file(module, attributes=attributes)

finder = SourceFinder()
filename = finder.find_import()

if filename:
    vim.command('return "%s"' % (filename))
EOF
endfunction

function! python#Source(type)
    let filename = s:FindPythonSource()

    if !filereadable(filename)
        echoerr "Could not open source. ".filename
    else
        if a:type == 'tab'
            exec 'tabnew '.filename
        elseif a:type == 'split'
            exec 'split '.filename
        elseif a:type == 'vsplit'
            exec 'vsplit '.filename
        endif
    endif
endfunction

nmap <leader>sft :call python#Source('tab')<CR>
nmap <leader>sfs :call python#Source('split')<CR>
nmap <leader>sfv :call python#Source('vsplit')<CR>
