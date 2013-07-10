# Guard Jekyll Plus

A Guard plugin for smarter Jekyll watching.

Features:

- Changing static files won't trigger a jekyll build! Files are copied/removed instead.
- Batched processing! (Adding a directory of `n` files triggers a single build)
- Reads options from your YAML config file(s)
- Supports multiple config files (Jekyll 1.0)
- Clear and colorized output

Here's a look

![Colorized output](http://cl.ly/QAK9/content.png)

## Installation

If using Bundler, add this line to your application's Gemfile:

    gem 'guard-jekyll-plus'

And then run:

    $ bundle

Or install it manually with:

    $ gem install guard-jekyll-plus


## Usage

Navigate to your Jekyll project directory and create a Guardfile using:

    $ guard init jekyll

Or if you already have a Guardfile, add a Jekyll guard.

```ruby
guard :jekyll do
  watch /.*/
  ignore /^_site/
end
```

Run the guard and Jekyll will begin watching your project.

    $ guard

If your Jekyll project has a non-standard directory stucture like this:

```
- source/
- public/
  _config.yml
```

You would do this instead:

```ruby
guard :jekyll do
  watch /^source/
  watch /_config.yml/
end
```

For the most part that's all you'll ever need to do. There are some things you can configure though.

## Configuration

This guard has two configurations.

| Config       | Description                                      | Default
|:-------------|:-------------------------------------------------|:---------------------------------------------------------------------------|
| `extensions` | Array of file extensions to trigger Jekyll build | ['md', 'mkd', 'markdown', 'textile', 'html', 'haml', 'slim', 'xml', 'yml'] |
| `config`     | Array of configuration files                     | ['_config.yml']                                                            |
| `serve`      | Use Jekyll's build in WEBrick server             | false                                                                      |

**Note:** customizations to the `extensions` configuration are additive.

### Configuring Jekyll watched file extensions

Here's how you would add `txt` to the list of file extensions which triggers a Jekyll build.

```ruby
guard :jekyll, :extensions => ['txt'] do
  watch /.*/
  ignore /^_site/
end
```

Now Guard will be watching for changes to txt, md, mkd, markdown, textile, html, haml, slim, xml, yml files. When these files change Guard will trigger a Jekyll build. Files
which don't match these extensions will be simply copied over to the destination directory when a change occurs, or deleted if appropriate.

### Configuring Jekyll config file

Here's how you might tell Jekyll to read from multiple configuration files.

```ruby
guard :jekyll, :config => ['settings.yml', 'override.yml'] do
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
