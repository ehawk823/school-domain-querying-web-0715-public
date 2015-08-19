require 'pry'

class Course
  attr_accessor :id, :name, :department_id, :department
  @@instances = []

  def initialize (id=nil, name=nil, department_id=nil)
    @id = id
    @name = name
    @department_id = department_id
    @students = []
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS courses (
    id INTEGER PRIMARY KEY,
    name TEXT,
    department_id INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def insert
    sql = <<-SQL
    INSERT INTO courses
    (name, department_id)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, name, department_id)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM courses")[0][0]
  end

  def self.new_from_db(row)
    star = Course.new
    star.id = row.flatten[0]
    star.name = row.flatten[1]
    star.department_id = row.flatten[2]
    star
  end

  def self.find_by_name(input)
    sql = <<-SQL
    SELECT * FROM courses
    WHERE name = ?
    SQL
    DB[:conn].execute(sql, input).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_all_by_department_id(input)
    sql = <<-SQL
    SELECT * FROM courses
    WHERE department_id = ?
    SQL
    DB[:conn].execute(sql, input).map do |row|
      self.new_from_db(row)
    end
  end

  def update
    sql = <<-SQL
    UPDATE courses
    SET name = ?, department_id = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, department_id, id)
  end

  def persisted?
    !!id
  end

  def save
    if persisted?
      update
    else
      insert
    end
  end

  def department
      @department = Department.find_by_id(@department_id)
  end

  def department=(department)
    @department = department
    @department_id = department.id
    save
    # binding.pry
  end

  def students
    @students
  end

  def add_student(student)
    student.add_course(self)
    save
    @students << student
  end
end
