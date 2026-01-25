require 'digest'
require 'fileutils'
require 'tty-progressbar'

class Deduplicator
  attr_reader :source_path, :dry_run

  def initialize(source_path, dry_run: false)
    @source_path = source_path
    @dry_run = dry_run
    @hash_map = {}
    @duplicates_count = 0
    @total_files = 0
  end

  def process
    files = collect_files
    @total_files = files.size

    puts "Calculating SHA256 hashes for #{@total_files} files..."
    bar = TTY::ProgressBar.new("[:bar] :percent :eta", total: @total_files)

    files.each do |file_path|
      begin
        hash = calculate_hash(file_path)
        
        if @hash_map[hash]
          @hash_map[hash] << file_path
          handle_duplicate(file_path)
        else
          @hash_map[hash] = [file_path]
        end
      rescue => e
        puts "\nWarning: Could not process #{file_path}: #{e.message}"
      end
      
      bar.advance(1)
    end

    {
      total_files: @total_files,
      duplicates_count: @duplicates_count,
      unique_files: @hash_map.keys.size
    }
  end

  private

  def collect_files
    files = []
    Find.find(@source_path) do |path|
      next if File.directory?(path)
      next if path.include?('_archive')
      files << path
    end
    files
  end

  def calculate_hash(file_path)
    Digest::SHA256.file(file_path).hexdigest
  end

  def handle_duplicate(file_path)
    @duplicates_count += 1
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    archive_dir = File.join(@source_path, '_archive', 'duplicates', timestamp)
    
    relative_path = file_path.sub(@source_path + '/', '')
    destination = File.join(archive_dir, relative_path)

    if @dry_run
      puts "[DRY RUN] Would move duplicate: #{relative_path} -> _archive/duplicates/#{timestamp}/"
    else
      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.mv(file_path, destination)
    end
  end
end
