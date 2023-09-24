# frozen_string_literal: true
require 'docsplit'
require 'csv'


# The coolest program
class PdfConverter
  attr_reader :outputName
  attr_reader :inputName
  attr_reader :title
  attr_reader :author
  def initialize(inputName, outputPath = "output/")
    @inputName = inputName
    @intermediateName = "outfile.html"
    @intermediateNameFull = @intermediateName + ".xml"
    @outputName = outputPath + "/" + File.basename(@inputName, File.extname(@inputName)) + '.CSV'
    @table = readTable
  end

  def pdf2xml
    temp = `pdftohtml -enc UTF-8 -noframes -c -xml -hidden #{@inputName} #{@intermediateName}`
  end

  def readTable
    # Create intermediate file
    pdf2xml

    table = File.read(@intermediateNameFull)

    # Delete png files
    # FIX: workaround as pdftohtml has no obvious option to surpress png file generation
    temp = `rm -r *.png`
    return table
  end

  def parseCurrency
    keyWord = "<b>Betrag"
    currency = @table.split(keyWord)[1].split(" ")[0]
    keyWord = "</b>"
    currency = currency.split(keyWord)[0]

    return currency
  end

  def parseFullConto
    keyWord = "Privatgirokonto"
    fullConto = @table.split(keyWord)[1].split("<\/b><\/text>")[0].split(",")[1][1..-1]

    return fullConto
  end

  def parseBookingDate(idx)
    bookingDate = @table.scan(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)[idx][0]
    bookingDate = bookingDate.split(" ")[0]

    return bookingDate
  end

  def parseValidDate(idx)
    validDate = @table.scan(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)[idx][0]
    validDate = validDate.split(" ")[1]

    return validDate
  end

  def parseValue(idx)
    scans = @table.split(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)
    entry = scans[(idx+1)*2]

    if entry.include? "height=\"20\" font=\"1"
      value = entry.split("width=\"148\" height=\"20\" font=\"1")[1].split("<\/text>")[0].split(" ")[-1]
    else 
      value = entry.split("width=\"148\" height=\"19\" font=\"1")[1].split("<\/text>")[0].split(" ")[-1]
    end
    
    return value
  end

  def parseBookingText(idx)
    # validDate = @table.scan(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)[idx][0]
    scans = @table.split(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)
    # bookingText = @table.split(validDate)[1].split("</text>")[0][1..]
    bookingText = scans[(idx+1)*2].split("</text>")[0][1..]

    return bookingText
  end

  def parseUsage(idx)
    # validDate = @table.scan(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)[idx][0]
    prev = @table.split(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)[(idx+1)*2]
    temp = prev.split("</text>")[1].split("  ")
    if temp.length > 2
      usage = temp[-1]
    else
      usage = temp[1]
    end

    if usage.nil?
      usage = prev.split("</text>")[1].split("font=\"9\">")[1]
    end

    second_line_usage = "t=\"248\" width=\"277\" height=\"16\" font=\"9\">"
    if prev.include? second_line_usage
      second_line = prev.split(second_line_usage)[1].split("</text>")[0]
    else
      second_line = ""
    end

    usage += second_line

    return usage
  end

  def parseReceiver(idx)
    validDate = @table.scan(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)[idx][0]
    prev = @table.split(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/)[(idx+1)*2]
    temp = prev.split("</text>")[1]
    
    if temp.include? "  "
      if temp.include? "font=\"9\">"
        receiver = temp.split("  ")[0].split("font=\"9\">")[1]
      else
        receiver = temp.split("  ")[0].split("font=\"10\">")[1]
      end
    else
      if temp.include? "font=\"9\">"
        receiver = temp.split("font=\"9\">")[1]
      else
        receiver = temp.split("font=\"10\">")[1]
      end
    end

    return receiver
  end

  def getRow(idx)
    row = [parseFullConto, parseBookingDate(idx), parseValidDate(idx), parseBookingText(idx), parseUsage(idx), "", "", "", "", "", "", parseReceiver(idx), "", "", parseValue(idx), parseCurrency, "Umsatz gebucht"]
    return row
  end

  def loadHeaders
    headers = []
    CSV.foreach("templates/template.csv") do |row|
      row.each do |element|
        headers << element
      end
    end

    return headers
  end

  def writeCsv
    puts "Writing to CSV file"
    # Load template CSV to get header
    headers = loadHeaders

    # Save object in ouptut folder
    CSV.open(@outputName, "w") do |csv|
      csv << headers

      # Write to object
      nEntries = @table.scan(/(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/).length
      for i in 0..nEntries-1 do
        content = getRow(i)
        csv << content
       end
      
    end
  end
end
