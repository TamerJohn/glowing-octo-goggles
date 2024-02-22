require "pg"

class DatabasePersistance
  def initialize(logger)
    @db = PG.connect(dbname: "todo")
    @logger = logger
    # @session = session
    # @session[:lists] ||= []
  end
  
  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end
  
  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    
    tuple = result.first
    todos = find_todos_for_list(id)
    
    {id: tuple["id"], name: tuple["name"], todos: todos}
    # @session[:lists].find{ |list| list[:id] == id }
  end
  
  def all_lists
    sql = "SELECT * FROM LISTS"
    result = query(sql)
  
    result.map do |tuple|
      list_id = tuple["id"].to_i
      todos = find_todos_for_list(list_id)
      
      {id: list_id, name: tuple["name"], todos: todos}
    end
    # @session[:lists]
  end
  
  def delete_list(id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, id.to_i)
    # @session[:lists].reject! do |list|
      # list[:id] == id
    # end
  end
  
  def create_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, list_name)
    # id = next_element_id(@session[:lists])
    # @session[:lists] << { id: id, name: list_name, todos: [] }
  end
  
  def update_list_name(list_id, new_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    query(sql, new_name, list_id)
    # list = find_list(list_id)
    # list[:name] = list_name
  end
  
  def create_new_todo(list_id, todo_name)
    sql = "INSERT INTO todos (list_id, name) VALUES ($1, $2)"
    query(sql, list_id.to_i, todo_name)
    # list = find_list(list_id)
    # id = next_element_id(list[:todos])
    
    # list[:todos] << { id: id, name: todo_name, completed: false }
  end
  
  def delete_todo(list_id, todo_id)
    sql = "DELETE FROM todos WHERE id = $1 AND list_id = $2"
    query(sql, todo_id, list_id)
    # list = find_list(list_id)
    
    # list[:todos].reject! { |todo| todo[:id] == todo_id }
  end
  
  def update_todo_status(list_id, todo_id, completed)
    sql = "UPDATE todos SET completed = $1 WHERE list_id = $2 AND id = $3"
    query(sql, completed, list_id, todo_id)
    
    # list = find_list(list_id)
    
    # todo = list[:todos].find { |todo| todo[:id] == todo_id }
    # todo[:completed] = completed
  end
  
  def mark_all_todos_completed(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
    # list = find_list(list_id)
    
    # list[:todos].each do |todo|
    #   todo[:completed] = true
    # end
  end
  
  private 
  
  def find_todos_for_list(list_id)
    subquery = query("SELECT * FROM todos WHERE list_id = $1", list_id)
    todos = []
    
    subquery.each do |tuple|
      todos << { 
        id: tuple["id"].to_i,
        name: tuple["name"], 
        completed: tuple["completed"] == "t"
      }
    end
    
    todos
  end
end


