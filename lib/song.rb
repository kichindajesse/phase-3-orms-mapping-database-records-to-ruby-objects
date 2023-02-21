class Song
  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @name = name
    @album = album
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO songs (name, album)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.album)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    end

    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
    song
  end

  def self.new_from_db(row)
    id, name, album = row
    Song.new(name: name, album: album, id: id)
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM songs
    SQL

    rows = DB[:conn].execute(sql)
    rows.map { |row| self.new_from_db(row) }
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM songs WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row) if row
  end

  def update
    sql = <<-SQL
      UPDATE songs SET name = ?, album = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.album, self.id)
  end
end
