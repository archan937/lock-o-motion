# LockOMotion

**Note: LockOMotion has been rewritten as [MotionBundler](https://github.com/archan937/motion-bundler). You should use that instead of LockOMotion.**

Require and mock Ruby gems (including their dependencies) within RubyMotion applications

## Introduction

[RubyMotion](http://www.rubymotion.com) is one of the latest phenomenons in the world of Ruby. It allows you to develop and test native iOS applications (for iPhone and iPad) using the Ruby language.

One of the limitations is that you are not able to use any random Ruby gem you want. It either has to be RubyMotion aware (like [BubbleWrap](https://github.com/rubymotion/BubbleWrap)) or RubyMotion compatible (mostly when having as minimal gem dependencies as possible and without doing things like class and instance evaluation). You are not able to require files at runtime, but that is where `LockOMotion` hooks in as it handles requirements for you.

Please note that although it is a valuable asset, using LockOMotion will still not let you include any random Ruby gem. But it does bring us a few steps closer towards that point.

A possible strategy is to "mock" common Ruby gems (e.g. `yaml` or [HTTParty](https://github.com/jnunemaker/httparty)) using (semi) drop-in replacements which are hooked in using LockOMotion. Cause why do we have to eliminate Ruby gems because they use one or a few methods of a "blocking" Ruby dependency gem like `YAML.load`? Anyway, I very very well know that this is no more worth than a half solutation but it's more than nothing.

## Installation

### Add `LockOMotion` to your Gemfile

    gem "lock-o-motion"

### Install the gem dependencies

    $ bundle

## Usage

### Set up your `Gemfile` and `Rakefile`

You need to setup your `Gemfile` by separating RubyMotion aware Ruby gems from the ones that are not. Put the RubyMotion **unaware** gems in the `:lotion` (short for LockOMotion of course) Bundler group like this:

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
* `USER_MOCKS` - The directory in which user defined mock gems are located
* `GEM_MOCKS` - The directory in which LockOMotion mock gems are located
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
      gem "mab"
    end

A fragment of the generated `.lotion.rb` looks like this:

    module Lotion
      FILES = [
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib/motion/core_ext.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib/motion/lotion.rb",
        "/Users/paulengel/Sources/just_awesome/.lotion.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib/colorize.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/builder.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/indentation.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/version.rb",
        "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi.rb",
        "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi/cookie.rb",
        "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi/core.rb",
        "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi/util.rb",
        "./app/app_delegate.rb",
        "./app/controllers/awesome_controller.rb"
      ]
      DEPENDENCIES = {
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab.rb" => [
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib/motion/core_ext.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib/motion/lotion.rb",
          "/Users/paulengel/Sources/just_awesome/.lotion.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/version.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/indentation.rb",
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/builder.rb"
        ],
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb" => [
          "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi.rb"
        ],
        "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi.rb" => [
          "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi/core.rb",
          "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi/cookie.rb",
          "/Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/cgi/util.rb"
        ],
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib/motion/core_ext.rb" => [
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib/colorize.rb"
        ],
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib/motion/lotion.rb" => [
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib/colorize.rb"
        ],
        "/Users/paulengel/Sources/just_awesome/.lotion.rb" => [
          "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib/colorize.rb"
        ]
      }
      IGNORED_REQUIRES = []
      USER_MOCKS = "/Users/paulengel/Sources/just_awesome/mocks"
      GEM_MOCKS = "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib/lock-o-motion/mocks"
      LOAD_PATHS = [
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib",
        "/Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/colorize-0.5.8/lib",
        "/Library/RubyMotion/lib",

### Warnings at runtime

As said before, you are not able to require sources at runtime and you cannot do "dynamic code execution" using `class_eval` or `instance_eval` with string interpolation (passing blocks is possible though). LockOMotion warns you about these kind of statements.

#### Restricted method calls

Using the previous `Gemfile`, as Mab uses `class_eval` with string interpolation. The console output would look something like this:

    1.9.3 paulengel:just_awesome $ rake
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
       Warning Called `Mab::Mixin::HTML5.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb:201
       Warning Called `Mab::Mixin::HTML5.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb:201
       Warning Called `Mab::Mixin::HTML5.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb:201
       Warning Called `Mab::Mixin::HTML5.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb:201
       Warning Called `Mab::Mixin::HTML5.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb:201
       Warning Called `Mab::Mixin::HTML5.class_eval` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/mab-0.0.2/lib/mab/mixin.rb:201
       Warning Called `Mab::Mixin::HTML5.class_eval` from

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
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    2013-02-13 01:10:53.584 Just Awesome[57808:c07] lotion.rb:17:in `require:': cannot load such file -- oj (LoadError)
      from core_ext.rb:39:in `require:'
      from multi_json.rb:38:in `block in default_adapter'
      from multi_json.rb:36:in `default_adapter'
      from multi_json.rb:85:in `load_adapter:'
      from multi_json.rb:73:in `use:'
      from multi_json.rb:55:in `adapter'
      from multi_json.rb:114:in `current_adapter:'
      from multi_json.rb:100:in `load:'
       Warning Called `require "yajl"` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.6.0/lib/multi_json.rb:38
               Add within Lotion.setup block: app.require "yajl"
       Warning Called `require "multi_json/adapters/yajl"` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.6.0/lib/multi_json.rb:82
               Add within Lotion.setup block: app.require "multi_json/adapters/yajl"
    2013-02-13 01:10:53.728 Just Awesome[57808:c07] multi_json.rb:83:in `load_adapter:': uninitialized constant MultiJson::Adapters (NameError)
      from multi_json.rb:85:in `load_adapter:'
      from multi_json.rb:73:in `use:'

When applicable, you will get a warning about it. Here is the fragment of the warning:

       Warning Called `require "yajl"` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.6.0/lib/multi_json.rb:38
               Add within Lotion.setup block: app.require "yajl"
       Warning Called `require "multi_json/adapters/yajl"` from
               /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.6.0/lib/multi_json.rb:82
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
       Compile /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_json-1.6.0/lib/multi_json/adapters/yajl.rb
       Compile /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/yajl-ruby-1.1.0/lib/yajl.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Info.plist
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/PkgInfo
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    (main)> 2013-02-13 01:13:03.630 Just Awesome[57933:c07] uninitialized constant Yajl (NameError)

You can to try [mocking Ruby gems](https://github.com/archan937/lock-o-motion#mocking-ruby-gems) with drop-in replacements.

### Adding `lotion.rb`

LockOMotion provides a possibility to run Ruby code at startup. You can think of it as a Rails initializer. Just add a file called `lotion.rb` within the root directory of your RubyMotion application.

Let's say the root directory of your RubyMotion application is `/Users/paulengel/Sources/just_awesome`. Create a file at `/Users/paulengel/Sources/just_awesome/lotion.rb`.

When containing the following Ruby code:

    puts "Hello, I am `lotion.rb`"
    puts SlotMachine.class

Using the following `Gemfile`:

    source "http://rubygems.org"

    # RubyMotion awared gems
    gem "lock-o-motion"

    # RubyMotion unawared gems
    group :lotion do
      gem "slot_machine"
    end

The output will be as follows:

    1.9.3 paulengel:just_awesome $ rake
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    Hello, I am `lotion.rb`
    Module
    (main)>

### Mocking Ruby gems

LockOMotion is able to mock some of the `HTTParty` core methods (GET, POST, PUT, DELETE requests and HTTP Basic Authentication). With this achievement, we are able to use several Ruby gems which have `HTTParty` as gem dependency. The dependency will not be a blocking factor anymore when it comes to using the gem within a RubyMotion application.

When having the following situation:

**Gemfile**

    source "http://rubygems.org"

    # RubyMotion aware gems
    gem "lock-o-motion"

    # RubyMotion unaware gems
    group :lotion do
      gem "httparty"
    end

**Fragment of a defined UIViewController for instance**

    def viewDidLoad
      super
      puts HTTParty.get("https://github.com/archan937/lock-o-motion").parsed_response
    end

#### Without mocking

As opposed to having the `HTTParty` mock to our availability. The console output would look like this:

    1.9.3 paulengel:just_awesome $ rake
       Warning Could not resolve dependency "socket.so"
       Warning /Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/net/http.rb
               requires /Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/x86_64-darwin12.2.1/zlib.bundle
       Warning /Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/net/http.rb
               requires /Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/x86_64-darwin12.2.1/stringio.bundle
       Warning Skipped 'openssl' requirement
       Warning /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/httparty-0.10.1/lib/httparty.rb
               requires /Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/x86_64-darwin12.2.1/zlib.bundle
       Warning /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_xml-0.5.3/lib/multi_xml.rb
               requires /Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/x86_64-darwin12.2.1/bigdecimal.bundle
       Warning /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/multi_xml-0.5.3/lib/multi_xml.rb
               requires /Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/x86_64-darwin12.2.1/stringio.bundle
       Warning /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/httparty-0.10.1/lib/httparty/net_digest_auth.rb
               requires /Users/paulengel/.rvm/rubies/ruby-1.9.3-p374/lib/ruby/1.9.1/x86_64-darwin12.2.1/digest/md5.bundle
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    (main)> 2013-02-13 01:21:39.888 Just Awesome[59028:c07] lotion.rb:17:in `require:': cannot load such file -- pathname.so (LoadError)
      from core_ext.rb:39:in `require:'

#### With mocking

When we do have the `HTTParty` mock available, we can just leave the code as is and get a console output like this:

    1.9.3 paulengel:just_awesome $ rake
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
       Compile /Users/paulengel/.rvm/gems/ruby-1.9.3-p374/gems/lock-o-motion-0.1.1/lib/lock-o-motion/mocks/httparty.rb
       Compile ./app/controllers/awesome_controller.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    (main)>


    <!DOCTYPE html>
    <html>
      <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
        <meta charset='utf-8'>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <title>archan937/lock-o-motion · GitHub</title>
        <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
        <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
        <link rel="apple-touch-icon-precomposed" sizes="57x57" href="apple-touch-icon-114.png" />
        <link rel="apple-touch-icon-precomposed" sizes="114x114" href="apple-touch-icon-114.png" />
        <link rel="apple-touch-icon-precomposed" sizes="72x72" href="apple-touch-icon-144.png" />
        <link rel="apple-touch-icon-precomposed" sizes="144x144" href="apple-touch-icon-144.png" />
        <link rel="logo" type="image/svg" href="http://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
        <meta name="msapplication-TileImage"
    (main)>

#### So what's the point?

Maybe you are thinking why someone would do something like this. Well, after having mocked `HTTParty`, I now am able to use the [betty_resource](https://github.com/bettyblocks/betty_resource/tree/edge) gem for instance. At first, I could not use the `betty_resource` gem because it has `HTTParty` as gem dependency but since that problem is eliminated, I can.

As an example:

**Gemfile**

    source "http://rubygems.org"

    # RubyMotion aware gems
    gem "lock-o-motion"

    # RubyMotion unaware gems
    group :lotion do
      gem "betty_resource", :path => "/Users/paulengel/Sources/betty_resource"
    end

**Fragment of a defined UIViewController for instance**

    def viewDidLoad
      super
      puts HTTParty.get("https://github.com/archan937/lock-o-motion").parsed_response[0, 1000]
      puts BettyResource::Api.get("/models/2c449a396a6a46159cd5f256622fd75f/records/1").parsed_response
      puts BettyResource::Relation.get(1).inspect
      puts BettyResource::Relation.get(1).first_name
    end

When running the application:

    1.9.3 paulengel:just_awesome $ rake
         Build ./build/iPhoneSimulator-6.1-Development
       Compile /Users/paulengel/Sources/just_awesome/.lotion.rb
          Link ./build/iPhoneSimulator-6.1-Development/Just Awesome.app/Just Awesome
        Create ./build/iPhoneSimulator-6.1-Development/Just Awesome.dSYM
      Simulate ./build/iPhoneSimulator-6.1-Development/Just Awesome.app
    (main)>


    <!DOCTYPE html>
    <html>
      <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
        <meta charset='utf-8'>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <title>archan937/lock-o-motion · GitHub</title>
        <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
        <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
        <link rel="apple-touch-icon-precomposed" sizes="57x57" href="apple-touch-icon-114.png" />
        <link rel="apple-touch-icon-precomposed" sizes="114x114" href="apple-touch-icon-114.png" />
        <link rel="apple-touch-icon-precomposed" sizes="72x72" href="apple-touch-icon-144.png" />
        <link rel="apple-touch-icon-precomposed" sizes="144x144" href="apple-touch-icon-144.png" />
        <link rel="logo" type="image/svg" href="http://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
        <meta name="msapplication-TileImage"
    {"last_name"=>"Willemse", "first_name"=>"Daniel", "id"=>1}
    #<BettyResource::Relation @id=1 @last_name=<not loaded> @first_name=<not loaded>>
    Daniel
    (main)>

When you are only using gems which are maintained by yourself, you would not have to mock its dependencies of course. But you do when dealing with third party gems.

#### Creating mocks

I am planning on writing more "mocks" for common Ruby gems. But aside from mocks being defined within the LockOMotion gem sources, you can also define your own mocks within your RubyMotion application. Just add a directory called `mocks` within the root directory of the application and put the "mock sources" in it. The relative path of the mock source within that directory ensures a certain Ruby gem being mocked at compile time.

Let's say the root directory of your RubyMotion application is `/Users/paulengel/Sources/just_awesome`. If you want to mock `require "httparty"`, create a file at `/Users/paulengel/Sources/just_awesome/mocks/httparty.rb` containing the mock code. If you want to mock `require "net/http"`, create a file at `/Users/paulengel/Sources/just_awesome/mocks/net/http.rb`. Cool, huh?

As already mentioned within the introduction, I am very well aware of this not being a waterproof solution, but it helps us getting on track.

### Skipped requirements

There are a few Ruby file sources that LockOMotion will refuse to require:

* `pry`
* `openssl`

At the moment, you will have to find a replacement yourself.

## Closing words

With LockOMotion, I have tried to lower the threshold for using more Ruby gems within RubyMotion applications. Contributions are very much welcome. Please spread the word about `LockOMotion` when you like it! ^^

## Roadmap

* Support requiring static libraries / C extensions (e.g. `BigDecimal`)
* Support requiring [Parslet](https://github.com/kschiess/parslet)

## Contact me

For support, remarks and requests, please mail me at [paul.engel@holder.nl](mailto:paul.engel@holder.nl).

## License

Copyright (c) 2013 Paul Engel, released under the MIT license

[http://holder.nl](http://holder.nl) - [http://codehero.es](http://codehero.es) - [http://gettopup.com](http://gettopup.com) - [http://github.com/archan937](http://github.com/archan937) - [http://twitter.com/archan937](http://twitter.com/archan937) - [paul.engel@holder.nl](mailto:paul.engel@holder.nl)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
