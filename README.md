pysource.vim
============

Open up python source easily inside of VIM

Mappings
-----------------------
``<leader>sft`` opens up source in a new tab
``<leader>sfs`` opens up source in a new split
``<leader>sfv`` opens up source in a new vertical split


How-To
------------------------

When your cursor is on a line such as.
``from django.views.generic.list import ListView``
press ``<leader>sft`` will open up the list.py file in a new tab. It will
also work when the line is ``import argparse`` it will show the source for it.
