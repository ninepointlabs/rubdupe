require 'exifr/jpeg'

class FileAnalyzer
  TEXT_EXTENSIONS = %w[.txt .md .markdown .log .csv .json .xml .html .htm .rb .py .js .java .c .cpp .h]
  
  def extract_text(file_path)
    ext = File.extname(file_path).downcase
    
    if TEXT_EXTENSIONS.include?(ext)
      File.read(file_path, encoding: 'UTF-8')
    elsif ext == '.jpg' || ext == '.jpeg'
      extract_exif_data(file_path)
    else
      nil
    end
  rescue => e
    nil
  end

  def detect_mime_type(file_path)
    output = `file --mime-type -b "#{file_path}" 2>/dev/null`.strip
    output.empty? ? 'application/octet-stream' : output
  rescue
    'application/octet-stream'
  end

  def extract_exif_data(file_path)
    exif = EXIFR::JPEG.new(file_path)
    return nil unless exif
    
    data = []
    data << exif.model if exif.model
    data << exif.date_time.to_s if exif.date_time
    data << exif.make if exif.make
    
    data.join(' ')
  rescue
    nil
  end
end
