class Search
  def initialize(query)
    @query = query
  end

  def all
    returned = results(@query).flatten.compact
  end


  protected

  def results(query)
    Searchable.where("name LIKE ?", "%#{query}%").all + sequence_results(query)
  end

  def sequence_results(query)
    [NoteSequence, ChordSequence, ChordNoteSequence].map do |klass|
      klass[query]
    end.flatten.compact.map do |result|
      Searchable.new(:target => result)
    end
  end
end
