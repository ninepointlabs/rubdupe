require 'classifier-reborn'
require 'fileutils'
require_relative 'file_analyzer'

class IntelligentSorter
  attr_reader :source_path, :dry_run

  def initialize(source_path, dry_run: false)
    @source_path = source_path
    @dry_run = dry_run
    @classifier = ClassifierReborn::Bayes.new
    @categories = {}
    @file_analyzer = FileAnalyzer.new
  end

  def train
    categories = discover_categories
    files_trained = 0

    categories.each do |category, files|
      files.each do |file|
        content = @file_analyzer.extract_text(file)
        next if content.nil? || content.strip.empty?
        
        @classifier.train(category, content)
        files_trained += 1
      end
    end

    { categories: categories.keys, files_trained: files_trained }
  end

  def sort_files
    train
    
    unsorted_files = collect_unsorted_files
    category_counts = Hash.new(0)

    unsorted_files.each do |file|
      category = classify_file(file)
      next unless category
      
      category_counts[category] += 1
      move_to_category(file, category)
    end

    { categories: category_counts }
  end

  private

  def discover_categories
    categories = Hash.new { |h, k| h[k] = [] }
    
    Dir.glob(File.join(@source_path, '*')).each do |path|
      next unless File.directory?(path)
      next if File.basename(path).start_with?('_')
      
      category_name = File.basename(path)
      
      Dir.glob(File.join(path, '**', '*')).each do |file|
        next if File.directory?(file)
        categories[category_name] << file
      end
    end
    
    categories
  end

  def collect_unsorted_files
    files = []
    
    Dir.glob(File.join(@source_path, '*')).each do |path|
      next if File.directory?(path)
      files << path
    end
    
    files
  end

  def classify_file(file)
    content = @file_analyzer.extract_text(file)
    
    if content && !content.strip.empty?
      @classifier.classify(content)
    else
      fallback_classification(file)
    end
  rescue => e
    puts "Warning: Could not classify #{file}: #{e.message}"
    nil
  end

  def fallback_classification(file)
    mime_type = @file_analyzer.detect_mime_type(file)
    
    case mime_type
    when /^image\//
      'Images'
    when /^video\//
      'Videos'
    when /^audio\//
      'Audio'
    when /pdf$/
      'Documents'
    else
      'Uncategorized'
    end
  end

  def move_to_category(file, category)
    category_dir = File.join(@source_path, category)
    filename = File.basename(file)
    destination = File.join(category_dir, filename)

    if @dry_run
      puts "[DRY RUN] Would move: #{filename} -> #{category}/"
    else
      FileUtils.mkdir_p(category_dir)
      
      if File.exist?(destination)
        base = File.basename(filename, File.extname(filename))
        ext = File.extname(filename)
        counter = 1
        destination = File.join(category_dir, "#{base}_#{counter}#{ext}")
        counter += 1 while File.exist?(destination)
      end
      
      FileUtils.mv(file, destination)
    end
  end
end
