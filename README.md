# Guard Jekyll Plus

A Guard plugin for smarter Jekyll watching.

[![Gem Version](https://badge.fury.io/rb/guard-jekyll-plus.png)](http://badge.fury.io/rb/guard-jekyll-plus)

Features:

- Changing static files won't trigger a jekyll build! Files are copied/removed instead.
- Batched processing! (Adding a directory of `n` files triggers a single build)
- Reads options from your YAML config file(s)
- Supports multiple config files (Jekyll 1.0)
- Serve with Jekyll or Rack (just add rack to your gemfile)
- Clear and colorized output

If you want to compile javascripts, take a look at [guard-stitch-plus](https://github.com/imathis/guard-stitch-plus) and [jekyll-stitch-plus](https://github.com/imathis/jekyll-stitch-plus).

Here's a look

![Colorized output](http://cl.ly/Q9qK/content.png)

## Installation

If using Bundler, add this line to your application's Gemfile:

    gem 'guard-jekyll-plus'

And then run:

    $ bundle

Or install it manually with:

    $ gem install guard-jekyll-plus


## Usage

Navigate to your Jekyll project directory and create a Guardfile using:

    $ guard init jekyll-plus

Or if you already have a Guardfile, add a Jekyll guard.

```ruby
guard "jekyll-plus" do
  watch /.*/
  ignore /^_site/
end
```

Run the guard and Jekyll will begin watching your project.

    $ bundle exec guard

If your Jekyll project has a non-standard directory stucture like this:

```
- source/
- public/
  _config.yml
```

You would do this instead:

```ruby
guard "jekyll-plus" do
  watch /^source/
  watch /_config.yml/
end
```

For the most part that's all you'll ever need to do. There are some things you can configure though.

## Configuration

This guard has these configurations.

| Config        | Description                                      | Default
|:--------------|:-------------------------------------------------|:-----------------------------------------------------------------------------------|
| `extensions`  | Array of file extensions to trigger Jekyll build | ['md', 'mkd', 'mkdn', 'markdown', 'textile', 'html', 'haml', 'slim', 'xml', 'yml'] |
| `config`      | Array of configuration files                     | ['_config.yml']                                                                    |
| `serve`       | Serve your site with Jekyll or a Rack server     | false                                                                              |
| `drafts`      | Build your site with draft posts                 | false                                                                              |
| `future`      | Build your site with future dated posts          | false                                                                              |
| `config_hash` | Use a config hash instead of an array of files   | nil                                                                                |
| `silent`      | Slience all output other than exception message  | false                                                                              |
| `msg_prefix`  | Output messages are prefixed with with this      | 'Jekyll'                                                                           |
| `rack_config` | Optional configuration for using the rack server | nil                                                                                |

**Note:** customizations to the `extensions` configuration are additive.

### Using Jekyll Server

To use Jekyll's built-in server, simply set `:serve => true` in your rack options

```ruby
guard "jekyll-plus", :serve => true do
  watch /.*/
  ignore /^_site/
end
```

### Using Rack Server

Simply add `gem 'rack'` to your Gemfile and Jekyll Plus will use Rack instead with a [config file](lib/rack/config.ru) which redirects `404s` and auto-appends `index.html` to directory urls.
If you want to use [Thin](https://github.com/macournoyer/thin/), add `gem 'thin'` instead.

If you wish to use your own rack server configuration, simply drop a `config.ru` file into your site root, or use the option `:rack_config => 'path/to/config.ru'` to tell Jeklly Plus where to look for your rack config file.

### Configuring Jekyll watched file extensions

Here's how you would add `txt` to the list of file extensions which triggers a Jekyll build.

```ruby
guard "jekyll-plus", :extensions => ['txt'] do
  watch /.*/
  ignore /^_site/
end
```

Now Guard will be watching for changes to txt, md, mkd, markdown, textile, html, haml, slim, xml, yml files. When these files change Guard will trigger a Jekyll build. Files
which don't match these extensions will be simply copied over to the destination directory when a change occurs, or deleted if appropriate.

### Configuring Jekyll config file

Here's how you might tell Jekyll to read from multiple configuration files.

```ruby
guard "jekyll-plus", :config => ['settings.yml', 'override.yml'] do
  watch /.*/
  ignore /^_site/
end
```

## Contributing

If you find this to be busticated, let me know in the issues.

## License

Copyright (c) 2013 Brandon Mathis

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
