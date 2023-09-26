require_relative 'converter'

def iterate_folder(path)
    inputPath = path
    outputPath = path

    pdfs = Dir[inputPath + "/*.pdf"]
    pdfs += Dir[inputPath + "/*.PDF"]
    puts "Number of pdfs to be transformed: " + String(pdfs.length)

    # Iterate all pdf files in a folder
    for index in 0 ... pdfs.size
        converter = PdfConverter.new(pdfs[index], outputPath)
        puts "Output name: #{converter.outputName}"
        converter.writeCsv
    end
end
  
# Files to be done is 2017 and 2019
iterate_folder("data")
