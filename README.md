# SPK-PDF-CONVERTER #
This Ruby based script should convert a PDF file generated and downloaded
from Sparkasse into a CSV file.
It can be used by changing the path in `main.rb` when calling iterate_folder function.
The pdfs in that folder will be translated into CSV in the same folder.

## Prerequisites ##`
- Installed Ruby interpreter
- ```bundle install```
- ```apt-get update```
- ```apt-get upgrade```
- ```apt-get install graphicsmagick pdftk```
- ```apt-get install libpoppler-dev```

## Usage ##
- ```ruby lib/converter.rb```
- ```ruby lib/main.rb```

## Test ##
- ```ruby test/converter_test.rb```

## Links ##
- [Ruby project setup](https://dev.to/deciduously/setting-up-a-fresh-ruby-project-56o4)
- [Using Ruby docsplit gem](https://agustinustheoo.medium.com/handling-pdf-files-using-docsplit-and-ruby-on-rails-8528f87532a7)
- [Using Ruby for csv](https://medium.com/@ali_schlereth/working-with-csvs-in-ruby-43005e566901)
- [Read table from pdf](https://github.com/adworse/iguvium)

## Notes ##
- Packages are called **gems** in Ruby
- [Bundler](https://bundler.io/) is Ruby's environment and package manager
- A standard Ruby installation comes with Bundler preinstalled, otherwise run 
```gem install bundler```
- Ruby configuration and dependencies is handeled by a ```Gemfile```
- By running ```bundle install``` this file is implemented and documented
via a ```Gemfile.lock``` 
- Rake is a gem in Ruby used to build, like with a Make file
- For linting a gem called Rubocop is used
- Transform pdf to xml file: ```pdftohtml -enc UTF-8 -noframes -c -xml  data/test_file.pdf  outfile.html```

## TODO ##
- main file should not have fixed paths
