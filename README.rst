Yellow Brick Road
=================

Closure library on rails
------------------------

..  image:: http://i.imgur.com/BeZpM.jpg
    :align: right

Yellow-brick-road is a set of tools to integrate google `closure library <http://code.google.com/closure/library/>`_ and `soy closure template <http://code.google.com/closure/templates/>`_ into rails.

Setup
+++++

To use yellow-brick-road in rails, add the gem to ``Gemfile``:

::
  
  gem 'yellow-brick-road',
    :git => 'git://github.com/alitn/yellow-brick-road.git',
    :submodules => true

A copy of the closure library comes with the gem as a git submodule. The ``:submodules => true`` option is required to clone this copy.

Integrating closure library
+++++++++++++++++++++++++++

Yellow-brick-road provides a `sprockets <https://github.com/sstephenson/sprockets>`_ directive for requiring a closure root. Given ``my-closure-app/`` as a closure app directory, it can be required by:

::
  
  //= require_closure_root ./my-closure-app
  
This renders a couple of script tags:

::
  
  <script src="/assets/closure/goog/base.js" type="text/javascript"></script>
  <script src="/assets/closure-deps.js" type="text/javascript"></script>
  
The former tag is the base requirement for closure library.

The latter tag, generated using `depswriter.py <http://code.google.com/closure/library/docs/depswriter.html>`_, is the dependency structure of the closure application. When the required closure root is modified, this dependency file is regenerated. It is safe to ignore this file in source revision control.
