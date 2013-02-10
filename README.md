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

### Auto-generated `.lotion.rb`

LockOMotion generates a hidden Ruby file called `.lotion.rb` in which the following constants are defined:

* `FILES` - All Ruby sources registered with `Motion::Project::App.files`
* `DEPENDENCIES` - All file dependencies registered with `Motion::Project::App.files_dependencies`
* `IGNORED_REQUIRES` - Ignored file requires (declared in `Lotion.setup`)
* `LOAD_PATHS` - Available load paths after running `rake`
* `GEM_PATHS` - Available gem paths (resembles `Gem.latest_load_paths`)
* `REQUIRED` - All required files after running `rake`

At runtime, LockOMotion uses `.lotion.rb` for resolving Ruby sources. This makes it possible the print warnings as specific as possible which makes debugging a little easier.

#### Example

Let us say your `Gemfile` looks like the following:

    source "http://rubygems.org"

    # RubyMotion awared gems
    gem "lock-o-motion"

    # RubyMotion unawared gems
    group :lotion do
      gem "slot_machine"
    end

A fragment of the generated `.lotion.rb` looks like this:

    module Lotion
      FILES = [
        "/Users/paulengel/Sources/lock-o-motion/lib/motion/core_ext.rb",
        "/Users/paulengel/Sources/lock-o-motion/lib/motion/lotion.rb",
        "/Users/paulengel/Sources/just_awesome/.lotion.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib/colorize.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot_machine.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot_machine/slot.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot_machine/version.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/time_slot.rb",
        "./app/app_delegate.rb",
        "./app/controllers/awesome_controller.rb"
      ]
      DEPENDENCIES = {
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot_machine.rb" => [
          "/Users/paulengel/Sources/lock-o-motion/lib/motion/core_ext.rb",
          "/Users/paulengel/Sources/lock-o-motion/lib/motion/lotion.rb",
          "/Users/paulengel/Sources/just_awesome/.lotion.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot_machine/slot.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot_machine/version.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/time_slot.rb"
        ],
        "/Users/paulengel/Sources/lock-o-motion/lib/motion/core_ext.rb" => [
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib/colorize.rb"
        ],
        "/Users/paulengel/Sources/lock-o-motion/lib/motion/lotion.rb" => [
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib/colorize.rb"
        ],
        "/Users/paulengel/Sources/just_awesome/.lotion.rb" => [
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib/colorize.rb"
        ]
      }
      IGNORED_REQUIRES = []
      LOAD_PATHS = [
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib",
        "/Users/paulengel/Sources/lock-o-motion/lib",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib",
        "/Library/RubyMotion/lib",

### Warnings at runtime

As said before, you are not able to require sources at runtime and you cannot use "dynamic code execution" like `class_eval` or `instance_eval`. LockOMotion warns you about these kind of statements.

#### Restricted method calls

Using the same `Gemfile` as in the previous example. The console output would look something like this:

    1.9.3 paulengel:just_awesome $ rake
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
       Warning Called `Slot.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot.rb:5
       Warning Called `TimeSlot.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot.rb:5
    (main) >

You will need to solve this yourself e.g. by overriding the method for instance or by refactoring.

#### Runtime requirements

It is possible that a Ruby source file gets required later on at runtime. Such file requirements are not allowed. This is the case when using [MultiJSON](https://github.com/intridea/multi_json). Using the following `Gemfile`:

    source "http://rubygems.org"

    # RubyMotion awared gems
    gem "lock-o-motion"

    # RubyMotion unawared gems
    group :lotion do
      gem "multi_json"
    end

You will get the following console output:

    1.9.3 paulengel:just_awesome $ rake
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/lock-o-motion/lib/motion/lotion.rb
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    (main)> 2013-02-10 18:27:40.813 Just Awesome[73896:c07] lotion.rb:17:in `require:': cannot load such file -- oj (LoadError)
      from core_ext.rb:29:in `require:'
      from multi_json.rb:33:in `block in default_adapter'
      from multi_json.rb:31:in `default_adapter'
      from multi_json.rb:49:in `adapter'
      from multi_json.rb:108:in `current_adapter:'
      from multi_json.rb:94:in `load:'
      from awesome_controller.rb:11:in `viewDidLoad'
      from app_delegate.rb:13:in `application:didFinishLaunchingWithOptions:'
       Warning Called `require "yajl"` from /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.5.0/lib/multi_json.rb:33
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.5.0/lib/multi_json.rb:33
               Add within Lotion.setup block: app.require "yajl"
       Warning Called `require "multi_json/adapters/yajl"` from /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.5.0/lib/multi_json.rb:74
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.5.0/lib/multi_json.rb:74
               Add within Lotion.setup block: app.require "multi_json/adapters/yajl"
    2013-02-10 18:27:40.981 Just Awesome[73896:c07] multi_json.rb:75:in `load_adapter:': uninitialized constant MultiJson::Adapters (NameError)
      from multi_json.rb:65:in `use:'
      from multi_json.rb:49:in `adapter'

When applicable, you will get a warning about it. Here is the fragment of the warning:

       Warning Called `require "yajl"` from /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.5.0/lib/multi_json.rb:33
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.5.0/lib/multi_json.rb:33
               Add within Lotion.setup block: app.require "yajl"
       Warning Called `require "multi_json/adapters/yajl"` from /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.5.0/lib/multi_json.rb:74
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.5.0/lib/multi_json.rb:74
               Add within Lotion.setup block: app.require "multi_json/adapters/yajl"

The following section contains further information about how to correct this.

### Extending `Lotion.setup`

You can require additional Ruby sources using `Lotion.setup`. To correct the earlier require warnings, declare the setup as follows:

    Lotion.setup do |app|
      app.require "yajl"
      app.require "multi_json/adapters/yajl"
    end

### Requirement of `.bundle` files

As far as I know, you are not able to require `.bundle` files within a RubyMotion application. After adding the require statement within `Lotion.setup`, you will get the following warning:

    1.9.3 paulengel:just_awesome $ rake
       Warning /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/yajl-ruby-1.1.0/lib/yajl.rb
               requires /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/yajl-ruby-1.1.0/lib/yajl/yajl.bundle
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Info.plist
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/PkgInfo
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    (main)> 2013-02-10 18:40:02.534 Just Awesome[74192:c07] uninitialized constant Yajl (NameError)

You can to try [mocking Ruby gems](https://github.com/archan937/lock-o-motion#mocking-ruby-gems) with drop-in replacements.

### Adding `lotion.rb`

LockOMotion provides a possibility to run Ruby code at startup. You can think of it as a Rails initializer. Just add a file called `lotion.rb` within the root directory of your RubyMotion application.

Let's say the path of your RubyMotion is `/Users/paulengel/Sources/just_awesome`. Create a file as `/Users/paulengel/Sources/just_awesome/lotion.rb`. When containing the following:

    puts "Hello, I am `lotion.rb`"
    puts SlotMachine.class

The output will be as follows:

    1.9.3 paulengel:just_awesome $ rake
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
       Compile ./app/controllers/awesome_controller.rb
       Compile /Users/paulengel/Sources/just_awesome/lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Info.plist
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/PkgInfo
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    (main)>    Warning Called `Slot.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot.rb:5
       Warning Called `TimeSlot.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/slot_machine-0.1.0/lib/slot.rb:5
    Hello, I am `lotion.rb`
    Module
    (main)>

### Mocking Ruby gems

LockOMotion is able to mock `HTTParty` with `BubbleWrap::HTTP`. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

### Skipped requirements

There are a few Ruby file sources that LockOMotion refuses to require:

* `pry`
* `openssl`

At the moment, you will have to find a replacement yourself.

## Closing words

With LockOMotion, I have tried to lower the threshold for using more Ruby gems within RubyMotion applications. Contributions are very much welcome. Please spread the word about `LockOMotion` when you like it! ^^

## Contact me

For support, remarks and requests, please mail me at [paul.engel@holder.nl](mailto:paul.engel@holder.nl).

## License

Copyright (c) 2013 Paul Engel, released under the MIT license

[http://holder.nl](http://holder.nl) - [http://codehero.es](http://codehero.es) - [http://gettopup.com](http://gettopup.com) - [http://github.com/archan937](http://github.com/archan937) - [http://twitter.com/archan937](http://twitter.com/archan937) - [paul.engel@holder.nl](mailto:paul.engel@holder.nl)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.