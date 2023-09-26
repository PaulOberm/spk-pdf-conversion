# frozen_string_literal: true
require 'docsplit'
require 'csv'

class PdfConverter
  attr_reader :outputName
  attr_reader :inputName
  attr_reader :title
  attr_reader :author
  def initialize(inputName, outputPath = "output/")
    @date_template = /(\d{2}\.\d{2}\.\d{4} \d{2}\.\d{2}\.\d{4})/
    @default_split = "</text>"
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
    fullConto = @table.split(keyWord)[1]
    fullConto = fullConto.split(@default_split)[0].split(",")[1][1..-1]

    return fullConto
  end

  def parseBookingDate(idx)
    bookingDate = @table.scan(@date_template)[idx][0]
    bookingDate = bookingDate.split(" ")[0]

    return bookingDate
  end

  def parseValidDate(idx)
    validDate = @table.scan(@date_template)[idx][0]
    validDate = validDate.split(" ")[1]

    return validDate
  end

  def parseValue(idx)
    keyword = "width=\"148\" height=\"20\" font=\"1"
    scans = @table.split(@date_template)
    idx_mod = update_idx(idx)
    entry = scans[idx_mod]

    if entry.include? keyword
      value = entry.split(keyword)[1].split(@default_split)[0].split(" ")[-1]
    else 
      value = entry.split(keyword)[1].split(@default_split)[0].split(" ")[-1]
    end
    
    return value
  end

  def parseBookingText(idx)
    idx_mod = update_idx(idx)
    scans = @table.split(@date_template)
    bookingText = scans[idx_mod].split(@default_split)[0][1..]

    return bookingText
  end

  def parseUsage(idx)
    idx_mod = update_idx(idx)
    prev = @table.split(@date_template)[idx_mod]
    temp = prev.split(@default_split)[1].split("  ")
    if temp.length > 2
      usage = temp[-1]
    else
      usage = temp[1]
    end

    if usage.nil?
      usage = prev.split(@default_split)[1].split("font=\"9\">")[1]
    end

    second_line_usage = "t=\"248\" width=\"277\" height=\"16\" font=\"9\">"
    if prev.include? second_line_usage
      second_line = prev.split(second_line_usage)[1].split(@default_split)[0]
    else
      second_line = ""
    end

    usage += second_line

    return usage
  end

  def parseReceiver(idx)
    keyword = "font=\"9\">"
    idx_mod = update_idx(idx)
    prev = @table.split(@date_template)[idx_mod]
    temp = prev.split(@default_split)[1]
    
    if temp.include? "  "
      if temp.include? keyword
        receiver = temp.split("  ")[0].split(keyword)[1]
      else
        receiver = temp.split("  ")[0].split("font=\"10\">")[1]
      end
    else
      if temp.include? keyword
        receiver = temp.split(keyword)[1]
      else
        receiver = temp.split("font=\"10\">")[1]
      end
    end

    return receiver
  end

  def getRow(idx)
    row = [parseFullConto, parseBookingDate(idx), parseValidDate(idx), 
           parseBookingText(idx), parseUsage(idx), "", "", "", "", "", 
           "", parseReceiver(idx), "", "", parseValue(idx), 
           parseCurrency, "Umsatz gebucht"]
    return row
  end

  def update_idx(idx)
    idx = (idx+1)*2
    return idx
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
      nEntries = @table.scan(@date_template).length
      for i in 0..nEntries-1 do
        content = getRow(i)
        csv << content
       end
    end
  end
end
