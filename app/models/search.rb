class Search
  def initialize(query)
    @query = query
  end

  def all
    results(@query).flatten.compact
  end

  # Names of searchables matching the query, shortest (most general) first.
  def suggestions(limit = 8)
    matching(@query).reorder(Arel.sql("length(name)")).limit(limit).pluck(:name).uniq
  end

  protected

  def results(query)
    matching(query).to_a + sequence_results(query)
  end

  def matching(query)
    Searchable.where("name LIKE ?", "%#{Searchable.sanitize_sql_like(query)}%")
  end

  def sequence_results(query)
    [NoteSequence, ChordSequence, ChordNoteSequence].map do |klass|
      klass[query]
    end.flatten.compact.map do |result|
      Searchable.new(:target => result)
    end
  end
end
