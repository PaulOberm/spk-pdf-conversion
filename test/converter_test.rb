require 'minitest/autorun'
require_relative '../lib/converter'

class PdfConverterTest < Minitest::Test

  def test_parseCurrency
    assert_match PdfConverter.new("data/test_file.pdf").parseCurrency, "EUR"
  end

  def test_parseFullConto
    assert_match "DE", PdfConverter.new("data/test_file.pdf").parseFullConto
  end

  def test_parseBookingDate
    assert_match "2019", PdfConverter.new("data/test_file.pdf").parseBookingDate(0)
  end

  def test_parseValidDate
    assert_match "2019", PdfConverter.new("data/test_file.pdf").parseValidDate(0)
  end

  def test_parseValue
    assert_match "34", PdfConverter.new("data/test_file.pdf").parseValue(0)
  end

  def test_parseBookingText
    assert_match "Dauer", PdfConverter.new("data/test_file.pdf").parseBookingText(0)
  end

  def test_parseUsage
    assert_match "Miet", PdfConverter.new("data/test_file.pdf").parseUsage(0)
  end

  def test_parseReceiver
    assert_match "Dr.", PdfConverter.new("data/test_file.pdf").parseReceiver(0)
  end

  def test_getRow
    expectedRow = ["DE",
                   "2019",
                   "2019",
                   "Dauer",
                   "Miet", 
                   "", "", "", "", "", "", 
                   "Dr", "", "", 
                   "34", 
                   "EUR", 
                   "Umsatz gebucht"]
    assert_match expectedRow[0], PdfConverter.new("data/test_file.pdf").getRow(0)[0]
    assert_match expectedRow[1], PdfConverter.new("data/test_file.pdf").getRow(0)[1]
    assert_match expectedRow[2], PdfConverter.new("data/test_file.pdf").getRow(0)[2]
    assert_match expectedRow[3], PdfConverter.new("data/test_file.pdf").getRow(0)[3]
    assert_match expectedRow[4], PdfConverter.new("data/test_file.pdf").getRow(0)[4]
    assert_match expectedRow[10], PdfConverter.new("data/test_file.pdf").getRow(0)[10]
    assert_match expectedRow[14], PdfConverter.new("data/test_file.pdf").getRow(0)[14]
    assert_match expectedRow[15], PdfConverter.new("data/test_file.pdf").getRow(0)[15]
    assert_match expectedRow[16] , PdfConverter.new("data/test_file.pdf").getRow(0)[16]

    expectedRow_3 = ["DE",
                   "2019",
                   "2019",
                   "Daue",
                   "", 
                   "", "", "", "", "", "", 
                   "Pa", "", "", 
                   "1.0", 
                   "EUR", 
                   "Umsatz gebucht"]
    assert_match expectedRow_3[0], PdfConverter.new("data/test_file.pdf").getRow(2)[0]
    assert_match expectedRow_3[1], PdfConverter.new("data/test_file.pdf").getRow(2)[1]
    assert_match expectedRow_3[2], PdfConverter.new("data/test_file.pdf").getRow(2)[2]
    assert_match expectedRow_3[3], PdfConverter.new("data/test_file.pdf").getRow(2)[3]
    assert_match expectedRow_3[4], PdfConverter.new("data/test_file.pdf").getRow(2)[4]
    assert_match  expectedRow_3[10], PdfConverter.new("data/test_file.pdf").getRow(2)[10]
    assert_match  expectedRow_3[14], PdfConverter.new("data/test_file.pdf").getRow(2)[14]
    assert_match  expectedRow_3[15], PdfConverter.new("data/test_file.pdf").getRow(2)[15]
    assert_match  expectedRow_3[16], PdfConverter.new("data/test_file.pdf").getRow(2)[16]

    # Add test for same date entry
    expectedRow_4 = ["DE",
                   "2019",
                   "2019",
                   "Last",
                   "XXXXXX", 
                   "", "", "", "", "", "", 
                   "KREDITK", "", "", 
                   "79", 
                   "EUR", 
                   "Umsatz gebucht"]
    assert_match expectedRow_4[0], PdfConverter.new("data/test_file.pdf").getRow(3)[0]
    assert_match expectedRow_4[1], PdfConverter.new("data/test_file.pdf").getRow(3)[1]
    assert_match expectedRow_4[2], PdfConverter.new("data/test_file.pdf").getRow(3)[2]
    assert_match expectedRow_4[3], PdfConverter.new("data/test_file.pdf").getRow(3)[3]
    assert_match expectedRow_4[4], PdfConverter.new("data/test_file.pdf").getRow(3)[4]
    assert_match expectedRow_4[10], PdfConverter.new("data/test_file.pdf").getRow(3)[10]
    assert_match expectedRow_4[14], PdfConverter.new("data/test_file.pdf").getRow(3)[14]
    assert_match expectedRow_4[15], PdfConverter.new("data/test_file.pdf").getRow(3)[15]
    assert_match expectedRow_4[16], PdfConverter.new("data/test_file.pdf").getRow(3)[16]

    # Add test for same date entry
    expectedRow_5 = ["DE",
                   "2019",
                   "2019",
                   "Lastschrift",
                   "Mehr Infos unter:Ihre Mobilfunkr echnung.", 
                   "", "", "", "", "", "", 
                   "Telefonica ", "", "", 
                   "9-", 
                   "EUR", 
                   "Umsatz gebucht"]
    assert_match expectedRow_5[0], PdfConverter.new("data/test_file.pdf").getRow(14)[0]
    assert_match expectedRow_5[1], PdfConverter.new("data/test_file.pdf").getRow(14)[1]
    assert_match expectedRow_5[2], PdfConverter.new("data/test_file.pdf").getRow(14)[2]
    assert_match expectedRow_5[3], PdfConverter.new("data/test_file.pdf").getRow(14)[3]
    assert_match expectedRow_5[4], PdfConverter.new("data/test_file.pdf").getRow(14)[4]
    assert_match expectedRow_5[10], PdfConverter.new("data/test_file.pdf").getRow(14)[10]
    assert_match expectedRow_5[14], PdfConverter.new("data/test_file.pdf").getRow(14)[14]
    assert_match expectedRow_5[15], PdfConverter.new("data/test_file.pdf").getRow(14)[15]
    assert_match expectedRow_5[16], PdfConverter.new("data/test_file.pdf").getRow(14)[16]
  end

  def test_loadHeaders
    n_columns = 17
    headers = PdfConverter.new("data/test_file.pdf").loadHeaders

    assert_equal headers.length, n_columns
  end

  def test_writeCsv
    # Got value from pdf file plus header
    nRows = 18 + 1

    # Write csv file
    PdfConverter.new("data/test_file.pdf").writeCsv
    csvFileName = PdfConverter.new("data/test_file.pdf").outputName
    # Load csv file and read number of written rows
    n_rows_written = CSV.read(csvFileName).length

    assert_equal nRows, n_rows_written
  end
end
