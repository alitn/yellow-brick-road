Yellow Brick Road
=================

Closure library on rails
------------------------

..  image:: http://i.imgur.com/BeZpM.jpg
    :align: right

Yellow-brick-road is a set of tools to integrate google `closure library <http://code.google.com/closure/library/>`_ and `soy closure template <http://code.google.com/closure/templates/>`_ into rails. This gem is for:

* Automatic dependency generation of a closure library based application, just add the ``//= require_closure_root`` directive.

* Using soy templates as part of the closure library.

* Using stand-alone soy templates without closure library, just configure the gem add the ``.js.soy`` file in assets directory, and it gets compiled automatically.

* Using a managed closure library source which can be shared among rails applications.

Setup
+++++

To use yellow-brick-road in rails, add the gem to ``Gemfile``:

::
  
  gem 'yellow-brick-road'

Then use this generator for create an initializer:

::
  
  rails generate yellow_brick_road:install

Configuration
+++++++++++++

Using the internal closure library
''''''''''''''''''''''''''''''''''

Yellow-brick-road comes with an internal copy of the closure library. This is based on the `closure-library-wrapper <https://github.com/alitn/closure-library-wrapper>`_ gem which keep a `svn mirror of closure library <https://github.com/jarib/google-closure-library>`_ as a submodule.

Once the generator creates the initializer, it locks the closure library source by its commit id. You can change this commit id using ``closure_library_lock_at`` and `this git repository <https://github.com/jarib/google-closure-library>`_ .

Using your own closure library
''''''''''''''''''''''''''''''

An external closure library path can be configured by ``closure_library_root``.

Using standalone soy
''''''''''''''''''''

By setting ``standalone_soy = true`` sy templates can be compiled independent of closure library. See usage for more.

Usage
+++++

Integrating closure library
'''''''''''''''''''''''''''

Yellow-brick-road provides a `sprockets <https://github.com/sstephenson/sprockets>`_ directive for requiring a closure root. Given ``my-closure-app/`` as a closure app directory, it can be required by:

::
  
  //= require_closure_root ./my-closure-app
  
This renders a couple of script tags:

::
  
  <script src="/assets/closure/goog/base.js" type="text/javascript"></script>
  <script src="/assets/closure-deps.js" type="text/javascript"></script>
  
The former tag is the base requirement for closure library.

The latter tag, generated using `depswriter.py <http://code.google.com/closure/library/docs/depswriter.html>`_, is the dependency structure of the closure application. When the required closure root is modified, this dependency file is regenerated. It is safe to ignore this file in source revision control.

Soy templates used with closure library
'''''''''''''''''''''''''''''''''''''''

Requiring a ``.js.soy`` template works out-of-the-box:

::
  
  //= require simple.js.soy
  
By default, it is assumed that soy templates are used as part of the closure library. The gem adds the ``soyutils_usegoog.js`` file to closure dependency search path, and the soy templates get compiled with these options:

::
  
  --shouldProvideRequireSoyNamespaces
  --cssHandlingScheme goog
  --shouldGenerateJsdoc
  
This means that a template like this:

::
  
  {namespace myproject.templates}

  /**
   * Greets a person using "Hello" by default.
   * @param name The name of the person.
   * @param? greetingWord Optional greeting word to use instead of "Hello".
   */
  {template .hello}
    {if not $greetingWord}
      Hello {$name}!
    {else}
      {$greetingWord} {$name}!
    {/if}
  {/template}
  
is compiled to:

::
  
  // This file was automatically generated from simple.js.soy.
  // Please don't edit this file by hand.

  goog.provide('myproject.templates');

  goog.require('soy');
  goog.require('soy.StringBuilder');


  /**
   * @param {Object.<string, *>=} opt_data
   * @param {soy.StringBuilder=} opt_sb
   * @return {string}
   * @notypecheck
   */
  myproject.templates.hello = function(opt_data, opt_sb) {
    var output = opt_sb || new soy.StringBuilder();
    output.append((! opt_data.greetingWord) ? 'Hello ' + soy.$$escapeHtml(opt_data.name) + '!' :
     soy.$$escapeHtml(opt_data.greetingWord) + ' ' + soy.$$escapeHtml(opt_data.name) + '!');
    return opt_sb ? '' : output.toString();
  };

Standalone Soy templates
''''''''''''''''''''''''

Yellow-brick-road can also be used for automatic compilation of soy templates without the use of closure library. This helps to integrate soy templates with other javascript frameworks like backbone.js.

To do this, use ``standalone_soy = true`` in the initializer, then require the soy javascript utility, which is shipped with the gem:

::
  
  //= require soyutils.js
  //= require simple.js.soy

In this case, the above template is compiled to:

::
  
  // This file was automatically generated from simple.js.soy.
  // Please don't edit this file by hand.

  if (typeof myproject == 'undefined') { var myproject = {}; }
  if (typeof myproject.templates == 'undefined') { myproject.templates = {}; }


  myproject.templates.hello = function(opt_data, opt_sb) {
    var output = opt_sb || new soy.StringBuilder();
    output.append((! opt_data.greetingWord) ? 'Hello ' + soy.$$escapeHtml(opt_data.name) + '!' :
     soy.$$escapeHtml(opt_data.greetingWord) + ' ' + soy.$$escapeHtml(opt_data.name) + '!');
    return opt_sb ? '' : output.toString();
  };
  
