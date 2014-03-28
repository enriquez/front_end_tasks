# FrontEndTasks

Command line tool for client side web application development.

# Installation

```bash
$ gem install front_end_tasks
```

# Usage

The `fe` command will be available after installing Front End Tasks.

## build

Compiles the given html file by combining and minifying javascript and stylesheet tags according to speical html comments (see HTML Comments section). External references will be updated to be flattened to the same directory as the resulting combined javascript/css file.

```bash
$ fe build path/to/public_dir path/to/public_dir/index.html
```

# HTML Comments

## build:script

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

Note: Only script tags are allowed between build:script and /build html comments.

## build:style

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

Note: Only link tags are allowed between build:style and /build html comments.

# External References

Front End Tasks build will try to update any references to external files for you. These dependencies will be copied into the build directory, but their directory structure will be flattened... so keep the names of your dependent files unique.

## Stylesheets

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

The above file will be moved into the same directory as the combined stylesheet (remember that file paths from stylesheets are relative to the location of the calling stylesheet).

## Javascripts

Javascript files may reference external scripts as Workers.

The url referenced from a call to `new Worker(...)` is updated to be located in the same directory as the combined javascript file. For example, if the combined javascript file is located at js/scripts.min.js:

```js
var worker = new Worker('js/workers/worker.js')
```

Turns into

```js
var worker = new Worker('js/worker.min.js')
```

The worker.js file is updated to replace calls to `importScripts` with the contents of the imported scripts. The worker is then minified and saved in the new location.

# MIT License

Copyright (c) 2014 Mike Enriquez (mike@enriquez.me)

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
