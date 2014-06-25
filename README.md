# Topographer [![Gem Version](https://badge.fury.io/rb/topographer.png)](http://badge.fury.io/rb/topographer) [![Build Status](https://travis-ci.org/SciMed/topographer.png?branch=master)](https://travis-ci.org/SciMed/topographer)

Topographer is a gem that provides functionality to conveniently import from various data sources into
ActiveRecord or other ORM systems.  This accomplished by defining an input wrapper, a mapping from input data to
 models, and a strategy for use in persisting data.



## Installation

Add this line to your application's Gemfile:

    gem 'topographer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install topographer

## Usage

### Overview

##### How it works

Topographer user a data mapping defined by a Mapper object to transform values from a single input record onto a output record.

The general flow of importing data is as follows:

Topogapher::Importer.import_data is called with an instance of an input wrapper, an import class, a persistance strategy class, and a logger instance.

A call to the `.get_mapper` method of the import class produces an instance of Topographer::Importer::Mapper, which is used to transform data from the input record to the format needed for output.  A mapper is constructed with an associated model class, which is generally the ORM class being imported.

An instance of the persistance strategy class is created using the Mapper instance obtained from the input class.

Then each "row" of input data is yielded sequentially as an instance of `Topographer::Importer::Input::SourceData`, which is then passed to the `#input_record` method of the strategy instance.

The strategy instance is responsible for using its Mapper instance to transform the input record into output data and the persist it in some way.  Generally, this means that the input strategy uses the result of mapping the data to create a new instance of the Mapper's model class and persist it using the appropriate ORM record.

Each call to `#input_record` is expected to return an instance of `Topographer::Importer::Strategy::ImportStatus` which encapsulates information about the status of a particular row of input.

This instance of ImportStatus is then used to construct a log entry for the input record, which is added to the logger instance passed to `.import_data`.

### Getting started

Topographer provides a convenient installer Thor task which can be used to generate a scaffold to get it up and running in your
projects.  Invoking

    thor topographer:install --models=Model1 Model2 Model3

in your project's root path will add a import scaffolding to the lib folder in the following structure

* <project_root>/lib
  * **imports.rb**
    * the base namespace module for the scaffold
  * *imports/*
    * **base.rb**
      * the base import module which defines methods needed to run imports
    * **commandline_import.rb**
      * a commandline import which can be used to conveniently setup rake or thor tasks to drive maintenance imports or commandline data updates
    * **user_interface_import.rb**
    	- a user interface import which is meant to drive importing from the user interface.  This importer currently makes some assumptions about where uploaded files should be saved, so you may want to customize the `.store_upload` method to suit your needs
    	- additionally, a view, `<project_root>/app/views/shared/_import_log_dispay.html.erb` is added which will render the import log in application views.  It should be called as follows:

    		    <%= render 'shared/import_log_display', logger: @logger%>

    		where the logger instance variable is the result of a call to `Imports::UserInterfaceImport.import_spreadsheet`
    * **mappings.rb**
   		* namespace module for mappings
    * **runners.rb**
    	* namespace module for runners
    * **strategy.rb**
    	* namespace module for strategies
    * *mappings/*
    	* **base.rb**
    		* base mapping module that defines several convenience methods for creating model mappings
    	* A mapping template for each model passed into the installer *i.e. model1.rb, model2.rb, etc*
    * *runners/*
    	* **base.rb**
    		* defines the shared behavior for a runner object
    	* A runner class for each strategy.  By default, these runners are essentially identical and are meant to provide an easy place to define custom behavior needed to accompany the running of a paritcular import strategy.
    * *strategy/*
    	* A strategy class for each strategy defined by Topographer. These strategy classes are intended to provide developers with a straightforward path to implementing custom strategies or providing additional behavior to the existing import strategies.

### Defining mappings

Briefly, a mapping is a set of rules for translating from an imported row of data to the fields needed to represent an output record.  Topographer uses a Mapper, which is an object that encapsulates a mapping, to map input data into a hash of output values that are available to a strategy to create output records.

Mappings are defined as follows:

* Assume the following ActiveRecord class:

```rb

class Post < ActiveRecord::Base
  belongs_to: author, class_name: 'User'

  validates :author, presence: true
  validates :title, presence: true
  validates :body, presence: true
end

```

* with the following database columns:

		author_id: 	integer
		title: 		string
		summary:	string
		body:		string
		created:	date
		updated:	date
		rating: 	integer
		private: 	boolean, null: false

* and an import spreadsheet with the following columns

		Author Name | Title | Summary | Body | Created | Rating | Importable

	where data is to be imported only if the importable column's value is *'Yes'*, each imported post is to be given a private flag of *false*, each post's title should be titlized, and each post without a created date should be given a created date of April 1, 2014

Assuming that the import class for Posts is defined in `lib/imports/mappings/post.rb` in such a way that the instance method `import_mapping` is called to produce a mapping for data importing,

A mapping would be defined as follows:

```rb
        def import_mapping
	      Topographer::Importer.build_mapper(::Post) do |mapper|

	        mapper.required_mapping('Author Name', 'author_id') do |inputs|
	          author = User.find_by(name: inputs['Author Name'])

	          raise "Unable to find Author with name `#{inputs['Author Name']}`" unless author

	 		  author.id
	        end

	        mapper.required_mapping('Title', 'title') do |inputs|
	        	inputs['title'].titlize
	        end

	        mapper.required_mapping('Body', 'body')

	        mapper.optional_mapping('Summary', 'summary')

	        mapper.optional_mapping('Created', 'created') do |inputs|
	        	date = inputs['Created'] || Date.parse('1/4/2014')
	        end

	        mapper.optional_mapping('Rating', 'rating')

	        mapper.validation_field('Is Importable?', 'importable') do
	        	raise 'Not importable' unless inputs['importable'] == 'Yes'
	        end

	        mapper.default_value('private') do
	        	false
	        end

	      end
	    end
```

In the above method, the call to `Topographer::Importer.build_mapper` requires a model class as an agrument.  This argument becomes the model class for the resulting Mapper and is available to any Strategy that uses the Mapper.  Generally, this class should be the ORM class that one is trying to import.

The block that follows the call to `.build_mapper` receives an object that can be used to construct a mapping.  The mapping methods that are available are as follows:

* `#required_mapping`

	Adds a required mapping for one or more input columns to a single output column.  Required mappings mean that each input column is required to have a value for the mapping to be considered valid.  If there is a value missing for a particular row of input, then an mapping error will be generated for that row.

	**Arguments**

 	* input column(s) - either a single input column name or an array of input column names
	* output field - a single output field name
	* block - an optional mapping behavior block which recieves a hash of input column names and their associated values for a paricular input record

  When there is no behavior block defined, the resulting output field value is simply the value from the import sheet.

  When a behavior block is defined, the value returned by that block will be the value present for the output field.

  If the block raises an execption, it's message will be added to the row in question as a mapping error.

* `#optional_mapping`

	Optional mappings behave exactly as required mappings except that an optional mapping that has one or more input column values missing for a particulr import row will not be considered a mapping error

* `#validation_field`

	Validation field mappings allow for a column to be used to validate an import record without that column being mapped to an output field.
	* Arguments
		* validation name - a name for the validation - should be unique within the context of a single mapping
		* input column(s) - either a single input column name or an array on input column names
		* block - a required validation behavior block

	When the validation block raises an exeption, the input record is considered 'invalid' and a mapping error is generated

* `#key_field`

	Key fields define fields that are made available to strategies in order to look up a given output record.  They are primarily used during imports which require updating existing database records.

	* Arguments
		* output field - a single output field name

* `#default_value`

	Default value mappings are used to define a static default value for an output field across all imported records

	* Arguments
	  * output_field - the output field name to map the default value to
	  * block - a behavior block that returns the value to insert into the output field. This block is required.


* `#ignored_column`

	Ignored columns allow a mapping to explicitly ignore a column in the input data
	 * Arguments
	    * input column - the name of a single input column to ignore


### Importing data

Given the above mapping for a post import, one might import posts from within a rake task as follows:

```rb
logger = Imports::CommandLineImport.import_spreadsheet(
  '/var/www/apps/my_app/input_file.xlsx',
  Imports::Runners::ImportNewRecord,
  Imports::Mappings::Post
)
```	

at which point, logger will encapsulate a log of all each row processed in the input file.

### Adding new import strategies

Import strategies encapsulate the logic needed to persist the result of mapping a single input row in some way.  Every strategy will have access to an instance of Mapper which it can use to transform input data into output data.

In general, a strategy should use its mapper to transform input data, then it should persist that data in some way, either by creating a new record of the Mapper's model class or through some other means, and finally it should return an ImportStatus object that encapsulates information about the result of the mapping, the result of the persistance attempt, and any other errors that may have occured.

Currently Topographer defines basic strategies for importing new records, updating existing records, and either updating a record, or creating one if a matching record cannot be found.

Because import strategies often differ between projects, subclasses of these strategies are created as part of the Topographer install to facilitate defining custom behaviors.

**Check back soon for additional documentation concerning adding new strategies.**

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

