# LockOMotion

Require RubyGems (including their dependencies) within RubyMotion Apps

## Introduction

[RubyMotion](http://www.rubymotion.com) is one of the latest phenomenons in the world of Ruby. It allows you to develop and test native iOS applications (for iPhone and iPad) using the Ruby language.

One of the limitations is that you are not able to use any random Ruby gem you want. It either has to be RubyMotion aware (like [BubbleWrap](https://github.com/rubymotion/BubbleWrap)) or RubyMotion compatible (mostly when having as minimal gem dependencies as possible and without doing things like class and instance evaluation). You are not able to require files at runtime, but that is where `LockOMotion` hooks in as it handles requirements for you.

Please note that although it is a valuable asset, using LockOMotion will still not let you include any random Ruby gem. It does bring us a few steps closer towards that point.

A possible strategy is to "mock" common Ruby gems (e.g. `yaml` or [httparty](https://github.com/jnunemaker/httparty)) using (semi) drop-in replacements which are hooked in using LockOMotion. Why do we have to eliminate Ruby gems because they use one or a few methods of a "blocking" Ruby dependency gem like `YAML.load`? Well, I very very well know that this is no more worth than a half solutation but it's more than nothing.

## Installation

### Add `LockOMotion` to your Gemfile

    gem "lock-o-motion"

### Install the gem dependencies

    $ bundle

## Usage

### Set up your `Gemfile` and `Rakefile`

You need to setup your `Gemfile` by separating RubyMotion aware Ruby gems from the ones that are not. Put the RubyMotion *unaware* gems in the `:lotion` (short for LockOMotion of course) Bundler group like this:

    source "http://rubygems.org"

    # RubyMotion aware gems
    gem "lock-o-motion"
    gem "easy-button"

    # RubyMotion unaware gems
    group :lotion do
      gem "betty_resource"
    end

Add `Lotion.setup` at the end of your `Rakefile`:

    # -*- coding: utf-8 -*-

    # Use `rake config' to see complete project settings.
    $:.unshift "/Library/RubyMotion/lib"

    require "motion/project"
    require "bundler"
    Bundler.require

    Motion::Project::App.setup do |app|
      app.name = "Just Awesome"
      app.frameworks << "AVFoundation"
    end

    Lotion.setup

Run `bundle install` if you haven't already and then `rake` to run the application in your iOS-simulator. Voila! You're done ^^

### Warnings at runtime

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

### Using `Lotion.setup`

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Contact me

For support, remarks and requests, please mail me at [paul.engel@holder.nl](mailto:paul.engel@holder.nl).

## License

Copyright (c) 2013 Paul Engel, released under the MIT license

[http://holder.nl](http://holder.nl) - [http://codehero.es](http://codehero.es) - [http://gettopup.com](http://gettopup.com) - [http://github.com/archan937](http://github.com/archan937) - [http://twitter.com/archan937](http://twitter.com/archan937) - [paul.engel@holder.nl](mailto:paul.engel@holder.nl)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.