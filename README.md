# Front End Tasks

Command line tool for client side web application development. Great for develoeprs who prefer to write plain html, css, and javascript that works without any special pre-processing. This tool helps optimize, lint, and test that code.

## Installation

```bash
$ gem install front_end_tasks
```

The `fe` command will be available after installing Front End Tasks.

## Usage

Front End Tasks can be used from the command line or scripted with Ruby.

### build

Compiles the given html file by combining and minifying javascript and stylesheet tags according to speical html comments (see HTML Comments section).

```bash
$ fe build path/to/public_dir path/to/public_dir/index.html
```

```ruby
FrontEndTasks.build('path/to/public_dir', './build', ['path/to/public_dir/index.html'])
```

### server

Run a development server on localhost.

```bash
$ fe server --public_dir app/
```

```ruby
FrontEndTasks.server(:public_dir => './app')
```

### lint

Run the given files through JSLint.

```bash
$ fe lint app/js/file_to_lint.js app/js/another_file.js
```

```ruby
FrontEndTasks.lint('./app/js/file_to_lint.js', './app/js/another_file.js')
```

### spec

Run Jasmine specs

```bash
$ fe spec --source_files app/js/post.js --spec_files spec/PostSpec.js
```

```ruby
FrontEndTasks.spec({
  :source_files => ['app/js/post.js'],
  :spec_files   => ['spec/PostSpec.js']
})
```

### gzip

Create a compressed .gz version of the given files

```bash
$ fe gzip app/js/app.js app/js/home.js
```

```ruby
FrontEndTasks.gzip('app/js/app.js', 'app/js/home.js')
```

### list_scripts

List the javascript files that are included in the html (script tags) or js (importScripts) file

```bash
$ fe list_scripts ./app/index.html
```

```ruby
FrontEndTasks.list_scripts('./app/index.html')
```

## HTML Comments

### build:script

Combine and minify scripts. Takes an argument that specifies the resulting file. See the following example

```html
<!-- build:script js/scripts.min.js -->
<script src="/js/app.js"></script>
<script src="/js/home.js"></script>
<!-- /build -->
```

The above combine and minify app.js and home.js together into scripts.min.js

```html
<script src="/js/scripts.min.js"></script>
```

Note: Only script tags that reference local urls are allowed between build:script and /build html comments.

### build:style

Similar to build:script, but for stylesheets

```html
<!-- build:style css/styles.min.css -->
<link href="vendor/bootstrap-3.1.1-dist/css/bootstrap.css" rel="stylesheet">
<link href="css/app.css" rel="stylesheet">
<!-- /build -->
```

The above becomes

```html
<link href="css/styles.min.css" rel="stylesheet">
```

Note: Only link tags that reference local urls are allowed between build:style and /build html comments.

## External References

The build command will find any references to other files in the project and include them in the resulting build.

### Stylesheets

CSS Files may reference fonts, images, etc... by using `url(...)`.

The contents inside `url()` are flattened to the file's basename. For example:

```css
@font-face {
  src: url('../fonts/glyphicons-halflings-regular.eot');
}
```

Turns into

```css
@font-face {
  src: url('glyphicons-halflings-regular.eot');
}
```

The above font file will be moved into the same directory as the combined stylesheet (remember that file paths from stylesheets are relative to the location of the calling stylesheet).

Note: Since all the files references from stylesheets are placed in the same directory, the filenames must be unique.

### Javascripts

Javascript files may have references to worker scripts. For example:

```js
var worker = new Worker('/js/workers/worker.js')
```

The worker script references are kept the same. The worker script is copied to the build with the same directory structure. Worker scripts are then processed by replacing `importScripts` calls.

```js
importScripts('/js/workers/worker_helper.js')
```

The above is replaced with the contents of the given file, then the whole worker script is minified.

## MIT License

Copyright (c) 2014 Mike Enriquez (http://enriquez.me)

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
